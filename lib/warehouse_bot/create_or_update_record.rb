# frozen_string_literal: true

module WarehouseBot
  # This class represents an active record that has either been created or updated during the WarehouseBot invocation.
  # It is used by DatabaseSnapshot to keep track of what we already have, and what still needs to be created.
  class CreateOrUpdateRecord
    # Create a new CreateOrUpdateRecord from an active record in the database.
    #
    # @param [ActiveRecord] active_record
    def initialize(active_record)
      @id = active_record.id
      @klass = active_record.class
      @attributes = strip_active_record(active_record)
    end

    # Returns whether this is a new record.  Used by InnovationHistoyPoint to differentiate between records
    # that have been created or updated in this snapshot and those that were created in previous snapshots.
    # 
    # @return [True]
    def new_record?
      true  
    end
    
    # The record's id within the database.
    attr_reader :id

    # Compares the current CreateOrUpdateRecord with an active record.  Returns true if all attributes including
    # id and any foreign keys are the same, but excluding created_at and updated_at.
    #
    # @param [ActiveRecord] other
    # @return [Bool]
    def ==(other)
      @klass==other.class && @attributes == strip_active_record(other)
    end

    # Used in testing to retrieve specific fields.
    def [](field)
      @attributes[field]
    end

    # Writes to the database.  If the record already exists, simply updates it.  If the record does not exist, creates
    # it with the correct id.
    #
    # @return [Void]
    def write_to_db
      if @klass.find_by(id: id)
        klass.update_attributes(@attributes)
      else
        new_record = @klass.new(@attributes)
        new_record.id = self.id
        new_record.save(validations: false)
      end
    end

    private def strip_active_record(record)
      record.attributes.except!(:created_at, :updated_at)
    end
  end
end
