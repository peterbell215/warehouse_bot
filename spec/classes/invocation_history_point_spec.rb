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
      check_current(WarehouseBot.root, [10, 20, 30])
    end

    it 'correctly records two different paths of invocation' do
      WarehouseBot.reset_tree
      WarehouseBot.add_invocation_point('file 1', 10)
      WarehouseBot.add_invocation_point('file 1', 20)
      WarehouseBot.add_invocation_point('file 1', 40)

      check_current(WarehouseBot.root, [10, 20, [30, 40]])
    end

    def check_current(current, linenos)
      if linenos.first.is_a?(Array)
        check_current_array(current, linenos)
      else
        check_current_line(current, linenos)
      end
    end

    def check_current_array(current, linenos)
      linenos.first.each_with_index do |lineno, index|
        expect(current.descendants[index].path).to eq('file 1')
        expect(current.descendants[index].lineno).to eq(lineno)
        check_current(current.descendants[lineno], linenos.drop(1))
      end
    end

    def check_current_line(current, linenos)
      lineno = linenos.shift
      expect(current.descendants.size).to eq(1)
      expect(current.descendants[0].path).to eq('file 1')
      expect(current.descendants[0].lineno).to eq(lineno)
      check_current(current.descendants[0], linenos) unless linenos.empty?
    end
  end
end
