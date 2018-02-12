# frozen_string_literal: true

# Because we are using ActiveRecord and FactoryBot outside of Rails, this provides a simple test just to make
# sure that both are wroking as expected.
RSpec.describe WarehouseBot do
  before do
    FactoryBot.create(:author)
  end

  it 'does something useful' do
    expect(Author.first.name).to eq 'Test User'
  end
end