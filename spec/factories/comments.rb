

FactoryBot.define do
  factory :comment, class: Comment do
    factory :random_comment do
      title { Faker::StarWars.quote }
      comment { Faker::Lorem.paragraph }
      author_id { Author.order('RANDOM()').first }
    end

  end
end
