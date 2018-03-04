# frozen_string_literal: true

RSpec.describe WarehouseBot do
  it 'has a version number' do
    expect(WarehouseBot::VERSION).not_to be nil
  end

  describe 'testing normal usage - level 1' do
    before(:all) { WarehouseBot.clear_tree }

    before(:each) { create_db_content }

    specify { expect(Author.count).to eq(5) }

    describe 'testing normal usage - level 2' do
      before do
        WarehouseBot.db_setup do
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

  describe 'with a pre-seeded database' do
    before(:all) { WarehouseBot.clear_tree }

    before(:each) { FactoryBot.create :author, name: 'Seeded Author' }

    specify { expect(Author.find_by(name: 'Seeded Author')).not_to be_nil }

    describe 'testing pre-seeded usage - level 1' do
      before { create_db_content }

      specify do
        expect(Author.count).to eq(6)
        expect(Author.find_by(name: 'Seeded Author')).not_to be_nil
      end

      describe 'testing pre-seeded usage - level 2' do
        before { add_extra_author }

        specify do
          expect(Author.count).to eq(7)
          expect(@block_expected).to be true
          expect(Author.find_by(name: 'Seeded Author')).not_to be_nil
        end

        specify 'this time - FactoryBot should not be called' do
          expect(@block_expected).to be_nil
          expect(Author.count).to eq(7)
          expect(Author.find_by(name: 'Seeded Author')).not_to be_nil
        end
      end
    end
  end

  describe 'in combination with FactoryBot and let' do
    before(:all) { WarehouseBot.clear_tree }

    let(:test_let) { @let_called = true; WarehouseBot.find_or_create :author }

    specify { expect(test_let.name).to eq('Test User') }

    describe 'in combination with FactoryBot and let - level 2' do
      let(:test_let_2) { author = WarehouseBot.find_or_create :author, name: 'Snapshot 2 Author' }

      specify { expect(@let_called). to be_nil }
      specify { expect(test_let.name).to eq('Test User') }
      specify { expect(test_let_2.name).to eq('Snapshot 2 Author') }
    end
  end

  describe 'dealing with foreign key constraint and wrong sequence of tables' do
    before(:all) { WarehouseBot.clear_tree }

    specify do
      # This will create the tables in the wrong order.
      allow(ApplicationRecord).to receive(:descendants).and_return([Posting, Author, Comments::Comment])

      create_db_content
    end
  end

  describe 'using a joing table' do
    before(:all) { WarehouseBot.clear_tree }

    specify 'first time HABTM table entries created' do
      create_db_content
      expect(Posting.first.categories).not_to be_empty
    end

    specify 'second time HABTM table entries reloaded' do
      create_db_content
      expect(Posting.first.categories).not_to be_empty
    end
  end

  def create_db_content
    WarehouseBot.reset_tree

    WarehouseBot.db_setup do
      FactoryBot.create_list :category, 5

      5.times do
        author = FactoryBot.create :random_author
        FactoryBot.create_list :posting, Random.rand(5), author_id: author.id
      end

      Posting.all.find_each do |posting|
        FactoryBot.create_list :random_comment, Random.rand(5), posting_id: posting.id
      end
    end
  end

  def add_extra_author
    WarehouseBot.db_setup do
      @block_expected = true

      author = FactoryBot.create :author, name: 'Snapshot 2 Author'
      FactoryBot.create :posting, author_id: author.id
    end
  end
end
