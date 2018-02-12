# frozen_string_literal: true

FactoryBot.define do
  factory :posting, class: Posting do
    factory :random_posting do
      title { Faker::StarWars.quote }
      description { Faker::Lorem.paragraph }
    end
  end
end
