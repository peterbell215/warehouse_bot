module WarehouseBot

  class ExistingRecord
    attr_reader :original_record

    def initialize(original_record)
      @original_record = original_record
    end

    def ==(active_record)
      original_record==active_record
    end
  end
end
