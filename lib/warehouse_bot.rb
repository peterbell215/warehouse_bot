# frozen_string_literal: true

require 'warehouse_bot/version'
require 'warehouse_bot/invocation_history_point'
require 'warehouse_bot/database_snapshot'

module WarehouseBot
  def self.warehouse_bot
    called_from = caller_locations(1, 1)

    pre_yield_db_state = current_position.database_state
    add_invocation_point(called_from[0].path, called_from[0].lineno)

    if current_position.database_state
      current_position.database_state.push_to_db
    else
      yield
      current_position.database_state = DatabaseSnapshot.new(pre_yield_db_state)
    end
  end

  # This is the top of the invocation tree.  As the RSpec tests run, we build up a history of how the warehouse_bot
  # is called.
  cattr_reader :root

  # Used in RSpec tests to reset the tree to initial load state of nil.
  def self.clear_tree
    @@root = nil
  end

  # This is our current position in the invocation tree.  Each time warehouse_bot gets invoke from Rspec, this is
  # updated.  This way, we can trace if the series of invocations is one we have seen before, and have therefore
  # saved some fixtures for it, or if we are seeing it for the first time.
  cattr_reader :current_position

  # Should be called at the start of each test run.  Will reset current position to the top of the invocation tree
  # to allow us to track our way through the tree anew.
  #
  # @return [InvocationHistoryPoint] current position
  def self.reset_tree
    @@root ||= InvocationHistoryPoint.new(nil, nil)
    @@current_position = @@root
  end

  def self.add_invocation_point(path, lineno)
    @@current_position =
      @@current_position.descendants.find { |invocation| invocation.path == path && invocation.lineno == lineno } ||
      InvocationHistoryPoint.new(path, lineno).tap { |new_point| @@current_position.descendants.push(new_point) }
  end
end
