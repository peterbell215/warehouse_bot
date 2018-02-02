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
end