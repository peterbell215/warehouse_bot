# frozen_string_literal: true

require 'warehouse_bot/version'
require 'warehouse_bot/invocation_history_point'
require 'warehouse_bot/database_snapshot'

module WarehouseBot
  # Called to create some background data.
  def self.db_setup(called_from = nil)
    called_from ||= caller_locations(1, 1)

    pre_yield_db_state = current_position.database_snapshot
    add_invocation_point(called_from[0].path, called_from[0].lineno)

    if current_position.database_snapshot
      current_position.database_snapshot.push_to_db
    else
      current_position.result = yield
      current_position.database_snapshot = DatabaseSnapshot.new(pre_yield_db_state)
    end
    current_position.result
  end

  # Often, we have the following construct in our Rspec code:
  #
  # let(:example) { FactoryBot.create :example }
  #
  # This method wraps the call to FactoryBot in an invocation of db_setup
  def self.find_or_create(name, *traits_and_overrides, &block)
    self.db_setup(caller_locations(1, 1)) do
      FactoryBot.create name, *traits_and_overrides, &block
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

  # Invocation points are the structure that records the tree like way that RSpec tests are built up.  An invocation
  # point is a specific file and line number.
  def self.add_invocation_point(path, lineno)
    @@current_position =
      @@current_position.descendants.find { |invocation| invocation.path == path && invocation.lineno == lineno } ||
      InvocationHistoryPoint.new(path, lineno).tap { |new_point| @@current_position.descendants.push(new_point) }
  end

  # The invocation may generate a result that we want to return in future calls.  This is particularly the case
  # if the find_or_create method is used.
  def self.add_result(result)
    @@current_position.result = result
  end
end
