# frozen_string_literal: true

RSpec.describe WarehouseBot do
  before do
    described_class.warehouse_bot do
      FactoryBot.create(:author)
    end
  end

  it 'has a version number' do
    expect(WarehouseBot::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(Author.first.name).to eq 'Test User'
  end
end
