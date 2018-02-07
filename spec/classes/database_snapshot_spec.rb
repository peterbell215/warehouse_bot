RSpec.describe WarehouseBot::InvocationHistoryPoint do
  describe 'creating a snapshot without a predecessor' do
    subject(:snapshot) { WarehouseBot::DatabaseSnapshot.new(nil) }

    before do
      5.times do
        author = FactoryBot.create :random_author
        FactoryBot.create_list :posting, Random.rand(5), author_id: author.id
      end

      #Posting.all.find_each do |posting|
      #  FactoryBot.create_list :random_comment, Random.rand(5), posting_id: posting.id
      #end
    end

    specify { expect(snapshot.previous_snapshot).to be_nil }
    specify { expect(snapshot.records[Author].size).to eq(5)}
    specify 'authors correctly held in snapshot' do
      authors_in_database = Set.new( Author.all.map(&:name) )
      authors_in_snapshot = Set.new( snapshot.records[Author].map{|record| record['name'] } )
      expect( authors_in_database ).to eq authors_in_snapshot
    end
  end
end