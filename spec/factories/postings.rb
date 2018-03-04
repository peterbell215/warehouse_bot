# frozen_string_literal: true

FactoryBot.define do
  factory :posting, class: Posting do
    factory :random_posting do
      title { Faker::StarWars.quote }
      description { Faker::Lorem.paragraph }
    end

    categories { Category.all.sample(rand(1..3)) }
  end
end
