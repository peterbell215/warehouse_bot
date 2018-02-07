# frozen_string_literal: true

module WarehouseBot
  # Objects in this class are used to represent an object that exists in the snapshot but has not changed from
  # a previous invocation.  It stores a reference to the original contract.
  class ExistingRecord
    attr_reader :original_record

    def initialize(original_record)
      @original_record = original_record
    end

    delegate :==, to: :original_record
  end
end
