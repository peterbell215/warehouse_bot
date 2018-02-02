RSpec.describe WarehouseBot do
  before do
    FactoryBot.create(:author)
  end

  it "has a version number" do
    expect(WarehouseBot::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(Author.first.name).to eq 'Test User'
  end
end
