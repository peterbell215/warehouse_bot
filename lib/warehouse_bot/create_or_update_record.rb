module WarehouseBot
  # This class represents an active record that has either been created or updated during the WarehouseBot invocation.
  # It is used by DatabaseSnapshot to keep track of what we already have, and what still needs to be created.
  class CreateOrUpdateRecord
    # Create a new CreateOrUpdateRecord from an active record in the database.
    def initialize(active_record)
      @id = active_record.id
      @klass = active_record.class
      @attributes = strip_active_record(active_record)
    end

    # The record's id within the database.
    attr_reader :id

    # Compares the current CreateOrUpdateRecord with an active record.  Returns true if all attributes including
    # id and any foreign keys are the same, but excluding created_at and updated_at.
    #
    # @return [Bool]
    def ==(active_record)
      @active_record.class==@klass && @attributes==strip_active_record(active_record)
    end

    # Used in testing to retrieve specific fields.
    def [](field)
      @attributes[field]
    end

    # Writes to the database.  If the record already exists, simply updates it.  If the record does not exist, creates
    # it with the correct id.
    def write_to_db
      existing_record = klass.find(id)
      if existing_record
        klass.update_attributes(@attributes)
      else
        new_record = klass.new(@attributes)
        new_record.id = self.id
        new_record.save(validations: false)
      end
    end

    private def strip_active_record(record)
      record.attributes.except!(:created_at, :updated_at)
    end
  end
end
