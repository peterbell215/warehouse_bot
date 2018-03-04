# frozen_string_literal: true

FactoryBot.define do
  factory :category, class: Category do
    name { Faker::ProgrammingLanguage.unique.name }
  end
end