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

      ordered_table_list.each do |klass|
        if previous_snapshot
          klass.find_each { |record| create_or_update(klass, record) }
        else
          klass.find_each { |record| push(klass, record) }
        end
      end
    end

    # Creates the ordered list of tables so that no records are written to the database before the parent records
    # have been written.
    # @return [Void]
    private def ordered_table_list
      return @ordered_table_list if @ordered_table_list

      @ordered_table_list = ApplicationRecord.descendants.keep_if { |klass| DatabaseSnapshot.relevant?(klass) }
      i = 0
      while i < @ordered_table_list.count - 1
        klass1 = @ordered_table_list[i]
        j = i + 1
        while j < @ordered_table_list.count
          klass2 = @ordered_table_list[j]
          if klass1.reflect_on_all_associations(:belongs_to).map(&:klass).include?(klass2)
            @ordered_table_list.delete_at(j)
            @ordered_table_list.insert(i, klass2)
            klass1 = klass2
            j = i + 1
          else
            j += 1
          end
        end
        i += 1
      end
      @ordered_table_list
    end

    # @param [Object] klass
    def self.relevant?(klass)
      !klass.count.zero? &&
        !klass.all.to_a.map(&:class).uniq.delete_if { |record_klass| klass != record_klass }.empty?
    end

    # Given a table class and a record, check if the record previously existed.  If so, we simply store a reference
    # to the first recording of the record.  If not, we create a new record also recording whether this is an update
    # or a genuinely new record.
    #
    # @api private
    # @param [Class] klass - table class being checked
    # @param [ActiveRecord] record record being checked
    # @return [Void]
    private def create_or_update(klass, record)
      previous_snapshot.records[klass].each do |historic_record|
        if historic_record == record
          return no_change(klass, historic_record)
        elsif historic_record.id == record.id
          return push(klass, record)
        end
      end
      push(klass, record)
    end

    # Called when the record is genuinely new.
    #
    # @api private
    # @param [Class] klass
    # @param [ActiveRecord] record
    private def push(klass, record)
      @records[klass].push CreateOrUpdateRecord.new(record)
    end

    # Called when the record is genuinely new.
    #
    # @api private
    # @param [Class] klass
    # @param [ActiveRecord] record
    private def no_change(klass, historic_record)
      @records[klass].push ExistingRecord.new(historic_record)
    end

    # Given a set of record, write them at speed to the database.
    #
    # @return [Void]
    def push_to_db
      records.each_key { |klass| write_class(klass) }
    end

    # Write new records for a specific.
    #
    # @param [Class] klass - the ActiveRecord class
    # @return [Void]
    def write_class(klass)
      recs = records[klass].dup.keep_if(&:new_record?)
      return if recs.empty?

      recs.delete_if { |record| klass.find_by(id: record.id)&.update_columns(record.attributes) }
      klass.import recs.map(&:attributes), validate: false
    end
  end
end
