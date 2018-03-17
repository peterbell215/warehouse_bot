# frozen_string_literal: true

require 'pathname'

module WarehouseBot
  # Represents a point at which WarehouseBot is invoked.
  class InvocationHistoryPoint
    # @param [String] path filename with path from which warehouse_bot was invoked
    # @param [Fixnum] lineno linenumber from which it was invoked
    def initialize(path, lineno, parent)
      @path = path
      @lineno = lineno
      @parent = parent

      @descendants = []
    end

    def inspect
      "#{_path_to_s}\nresult: #{result}"
    end

    # Generate a string relative to current working directive
    #
    # @api private
    # @return [String]
    def _path_to_s
      "#{_relative_path}:#{lineno}->#{(parent ? "#{parent._path_to_s}" : "\n")}"
    end

    # Returns the path relative to the CWD for the invocation file.
    # @api private
    def _relative_path
      Pathname.new(self.path).relative_path_from(Dir.pwd).to_s
    end

    # Generate a string showing either the database snapshot or a simple msg.
    #
    # @api private
    # @return [String]
    private def database_snapshot_to_s
      database_snapshot ? database_snapshot.inspect : 'no db snapshot'
    end

    attr_reader :path, :lineno, :parent, :descendants
    attr_accessor :database_snapshot

    attr_accessor :result
  end
end
