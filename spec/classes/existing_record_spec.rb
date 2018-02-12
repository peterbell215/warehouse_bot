# frozen_string_literal: true

RSpec.describe WarehouseBot::CreateOrUpdateRecord do
  subject { WarehouseBot::ExistingRecord.new(active_record) }

  let(:original_record) { WarehouseBot::CreateOrUpdateRecord.new(active_record) }
  let(:active_record) { FactoryBot.create :random_author }
  let(:another_active_recort) { FactoryBot.create :random_author }

  it { is_expected.to eq(active_record) }
  it { is_expected.not_to eq(another_active_recort) }
end