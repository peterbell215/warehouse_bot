# frozen_string_literal: true

RSpec.describe WarehouseBot::InvocationHistoryPoint do
  subject(:first_snapshot) { WarehouseBot::DatabaseSnapshot.new(nil) }

  before do
    5.times do
      author = FactoryBot.create :random_author
      FactoryBot.create_list :posting, 3, author_id: author.id
    end

    Posting.all.find_each do |posting|
      FactoryBot.create_list :random_comment, 4, posting_id: posting.id
    end
  end

  describe 'creating a snapshot without a predecessor' do
    specify { expect(first_snapshot.previous_snapshot).to be_nil }
    specify { expect(first_snapshot.records[Author].size).to eq(5) }
    specify 'authors correctly held in snapshot' do
      authors_in_database = Set.new(Author.all.map(&:name))
      authors_in_snapshot = Set.new(first_snapshot.records[Author].map { |record| record['name'] })
      expect(authors_in_database).to eq authors_in_snapshot
    end
  end

  describe '#inspect' do
    specify do
      expect(first_snapshot.inspect).to eq "[\n<Author: [1..5]>\n<Posting: [1..15]>\n<Comments::Comment: [1..60]>\n]"
    end
  end

  describe 'creating a series of snapshots' do
    subject(:second_snapshot) { WarehouseBot::DatabaseSnapshot.new(first_snapshot) }

    let(:original_snapshot_authors) { first_snapshot; Set.new(Author.all.map(&:name)) }

    before do
      original_snapshot_authors

      author = FactoryBot.create :author, name: 'Snapshot 2 Author'
      FactoryBot.create :posting, author_id: author.id
    end

    specify { expect(second_snapshot.previous_snapshot).to eql(first_snapshot) }
    specify { expect(second_snapshot.records[Author].size).to eq(6) }
    specify 'that 2nd snapshot holds new author and one comment' do
      second_snapshot.records[Author].any? { |record| record.new_record? && record['name'] == 'Snapshot 2 Author' }
    end
    specify 'that 2nd snapshot holds original authors' do
      original_authors = second_snapshot.records[Author].reduce(Set.new) do |set, record|
        record.new_record? ? set : set << record['name']
      end
      expect(original_snapshot_authors).to eq(original_authors)
    end
  end
end
