# frozen_string_literal: true

RSpec.describe WarehouseBot do
  before(:all) { WarehouseBot.clear_tree }

  it 'has a version number' do
    expect(WarehouseBot::VERSION).not_to be nil
  end

  describe 'testing normal usage - level 1' do
    before do
      WarehouseBot.reset_tree

      WarehouseBot.warehouse_bot do
        5.times do
          author = FactoryBot.create :random_author
          FactoryBot.create_list :posting, Random.rand(5), author_id: author.id
        end

        Posting.all.find_each do |posting|
          FactoryBot.create_list :random_comment, Random.rand(5), posting_id: posting.id
        end
      end
    end

    specify { expect(Author.count).to eq(5) }

    describe 'testing normal usage - level 2' do
      before do
        WarehouseBot.warehouse_bot do
          @block_expected = true

          author = FactoryBot.create :author, name: 'Snapshot 2 Author'
          FactoryBot.create :posting, author_id: author.id
        end
      end

      specify do
        expect(Author.count).to eq(6)
        expect(@block_expected).to be true
      end

      specify 'this time - FactoryBot should not be called' do
        expect(@block_expected).to be_nil
        expect(Author.count).to eq(6)
      end
    end
  end
end
