# frozen_string_literal: true

FactoryBot.define do
  factory :author, class: Author do
    factory :random_author, class: Author do
      name { Faker::Name.name }
    end
    name 'Test User'
  end
end
