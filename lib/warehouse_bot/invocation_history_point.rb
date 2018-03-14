# frozen_string_literal: true

module WarehouseBot
  # Represents a point at which WarehouseBot is invoked.
  class InvocationHistoryPoint
    # @param [String] path filename with path from which warehouse_bot was invoked
    # @param [Fixnum] lineno linenumber from which it was invoked
    def initialize(path, lineno)
      @path = path
      @lineno = lineno

      @descendants = []
    end

    def inspect
      "#{path.delete_prefix(Dir.pwd)}:#{lineno}\n#{database_snapshot ? database_snapshot.inspect : 'no db snapshot'}\nresult: #{result}"
    end

    attr_reader :path, :lineno, :descendants
    attr_accessor :database_snapshot

    attr_accessor :result
  end
end
