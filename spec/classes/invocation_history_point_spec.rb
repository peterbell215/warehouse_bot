# frozen_string_literal: true

RSpec.describe WarehouseBot::InvocationHistoryPoint do
  before do
    WarehouseBot.clear_tree
    WarehouseBot.reset_tree
  end

  describe 'first time it has an empty tree' do
    subject(:current_position) { WarehouseBot.current_position }

    specify { expect(current_position.path).to be_nil }
    specify { expect(current_position.lineno).to be_nil }
    specify { expect(current_position.descendants).to be_empty }
  end

  describe 'creates a tree' do
    before do
      WarehouseBot.add_invocation_point('file 1', 10)
      WarehouseBot.add_invocation_point('file 1', 20)
      WarehouseBot.add_invocation_point('file 1', 30)
    end

    it 'correctly records a linear history of invocation' do
      check_tree(WarehouseBot.root, [ { l: 10, d: [ { l:20, d: [ { l:30, d: []}]}]}])
    end

    it 'correctly records two different paths of invocation' do
      WarehouseBot.reset_tree
      WarehouseBot.add_invocation_point('file 1', 10)
      WarehouseBot.add_invocation_point('file 1', 20)
      WarehouseBot.add_invocation_point('file 1', 40)

      check_tree(WarehouseBot.root, [{ l: 10, d: [{ l:20, d: [{l: 30, d: []}, {l: 40, d: []}]}]}])
    end

    def check_tree(current, linenos)
      current.descendants.each_with_index do |descendant, i|
        return false unless check_node(descendant, linenos[i])
      end
      true
    end

    def check_node(current, linenos)
      current.lineno==linenos[:l] && check_tree(current, linenos[:d])
    end
  end
end
