# frozen_string_literal: true

RSpec.describe WarehouseBot::CreateOrUpdateRecord do
  subject { described_class.new(active_record) }

  let(:active_record) { FactoryBot.create :random_author }
  let(:another_active_recort) { FactoryBot.create :random_author }

  it { is_expected.to eq(active_record) }
  it { is_expected.not_to eq(another_active_recort) }

  specify 'record recreated with correct id' do
    active_record.delete
    expect(Author.find_by(id: subject.id)).to be_nil
    subject.write_to_db
    expect(Author.find(subject.id)).not_to be_nil
  end

  describe 'record updated on change' do
    let(:new_record) { described_class.new(active_record) }

    before do
      active_record.update!(name: 'changed name')
      new_record
      active_record.delete
      subject.write_to_db
    end

    specify do
      expect_any_instance_of(Author).to receive(:update_attributes).once
      new_record.write_to_db
    end
  end
end
