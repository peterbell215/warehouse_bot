

# frozen_string_literal: true

FactoryBot.define do
  factory :comment, class: Comments::Comment do
    factory :random_comment do
      title { Faker::StarWars.quote }
      comment { Faker::Lorem.paragraph }
      author_id { Author.order('RANDOM()').first }
    end
  end
end
