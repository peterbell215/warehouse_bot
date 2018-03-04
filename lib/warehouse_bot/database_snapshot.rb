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

    #
    attr_reader :has_and_belongs_to_tables

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

      set_has_and_belongs_to_tables
    end

    # Creates the ordered list of tables so that no records are written to the database before the parent records
    # have been written.
    #
    # @return [Void]
    private def ordered_table_list
      return @ordered_table_list if @ordered_table_list

      @ordered_table_list = ApplicationRecord.descendants.keep_if { |klass| DatabaseSnapshot.relevant?(klass) }
      i = 0
      while i < @ordered_table_list.count - 1
        klass1 = @ordered_table_list[i]
        klass1_belong_to = klass1.reflect_on_all_associations(:belongs_to).map(&:klass)
        j = i + 1
        while j < @ordered_table_list.count
          klass2 = @ordered_table_list[j]
          if klass1_belong_to.include?(klass2)
            @ordered_table_list.delete_at(j)
            @ordered_table_list.insert(i, klass2)
            klass1 = klass2
            klass1_belong_to = klass1.reflect_on_all_associations(:belongs_to).map(&:klass)
            j = i + 1
          else
            j += 1
          end
        end
        i += 1
      end
      @ordered_table_list
    end

    # Used by #ordered_private_list to weed out tables that are not relevant. Not relevant tables are those
    # without any records in the database, or where the table is STI and all table entries actually belong to a
    # child class.
    #
    # @param [Object] klass
    def self.relevant?(klass)
      !klass.count.zero? &&
        !klass.all.to_a.map(&:class).uniq.delete_if { |record_klass| klass != record_klass }.empty?
    end

    # This hash holds for each class a hash of the remote table, together with the members in that table.
    #
    # For example:
    #   { Category => [ { name: :postings, id: 1, foreign_keys: [1, 4, 7, 8] }, { name: postings, id: 2, foreign: [4, 5] } ]
    #     Posting => [ { name: :categories, id: 1: [3, 5, 9, 12] } ]
    #   }
    def set_has_and_belongs_to_tables
      @has_and_belongs_to_tables = Hash.new { |hash, key| hash[key] = [] }

      ordered_table_list.each do |klass|
        klass.reflect_on_all_associations(:has_and_belongs_to_many).each do |habtm|
          klass.find_each do |record|
            @has_and_belongs_to_tables[klass].push foreign_klass: habtm.klass, foreign_name: habtm.name, id: record.id,
                                                   foreign_keys: record.send(habtm.name).ids
          end
        end
      end
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
      has_and_belongs_to_tables.each_key { |klass| write_habtm(klass) }
    end

    # Write new records for a specific class.
    #
    # @param [Class] klass - the ActiveRecord class
    # @return [Void]
    def write_class(klass)
      recs = records[klass].dup.keep_if(&:new_record?)
      return if recs.empty?

      recs.delete_if { |record| klass.find_by(id: record.id)&.update_columns(record.attributes) }
      klass.import recs.map(&:attributes), validate: false
    end

    # Write the habtm tables for a specific class.  Note, we only write those HABTMs where the foreign key also exists.
    #
    #
    # @param [Class] klass - the ActiveRecord class
    def write_habtm(klass)
      has_and_belongs_to_tables[klass].each do |habtm_record|
        foreign_keys_that_exist = habtm_record[:foreign_keys] & habtm_record[:foreign_klass].ids

        unless foreign_keys_that_exist.empty?
          klass.find(habtm_record[:id]).association(habtm_record[:foreign_name]).ids_writer(foreign_keys_that_exist)
        end
      end
    end
  end
end
