# frozen_string_literal: true

require 'warehouse_bot/create_or_update_record'
require 'warehouse_bot/existing_record'

module WarehouseBot
  # Class used to represent a specific snapshot of the database after the yield from a WarehouseBot.warehouse_bot has
  # returned.
  class DatabaseSnapshot
    # This holds a reference to the previous snapshot of the DB.  This captures the state of the DB before
    # this update.
    attr_reader :previous_snapshot

    # This hash holds the records.  It maps each class/table to an array of CreateOrUpdateRecord(s) or
    # ExistingRecord(s).  The former is used if the record is new or has been updated in this invocation,
    # ExistingRecord is simply a reference back to the first CreateOrUpdateRecord with the current values.
    attr_reader :records

    # Creates a new snapshot that holds what has changed from the previous invocation.
    #
    # @param [DatabaseSnapshot] previous_snapshot last database snapshot
    def initialize(previous_snapshot)
      @previous_snapshot = previous_snapshot
      @records = Hash.new { |hash, key| hash[key] = [] }

      tables = ActiveRecord::Base.connection.tables.to_a - ['ar_internal_metadata']
      tables.each do |table|
        klass = table.classify.constantize
        klass.find_each { |record| create_or_update(klass, record) }
      end
    end

    # Given a table class and a record, check if the record previously existed.  If so, we simply store a reference
    # to the first recording of the record.  If not, we create a new record.
    #
    # @param [Class] klass - table class being checked
    # @param [ActiveRecord] record record being checked
    # @return [Void]
    def create_or_update(klass, record)
      return if previous_snapshot && find_in_previous_snapshot(klass, record)
      @records[klass].push CreateOrUpdateRecord.new(record)
    end

    # Used by create_or_update to see if the record already exists in the previous snapshot.
    private def find_in_previous_snapshot(klass, record)
      previous_snapshot.records[klass].each do |historic_record|
        if record == historic_record
          records[klass].push ExistingRecord.new(historic_record)
          return true
        end
      end
      false
    end
  end
end
