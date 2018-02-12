# frozen_string_literal: true

module WarehouseBot
  class InvocationHistoryPoint
    # @param [String] path filename with path from which warehouse_bot was invoked
    # @param [Fixnum] lineno linenumber from which it was invoked
    def initialize(path, lineno)
      @path = path
      @lineno = lineno

      @descendants = []
    end

    attr_reader :path, :lineno, :descendants
    attr_accessor :database_snapshot
  end
end
