# frozen_string_literal: true

FactoryBot.define do
  factory :category, class: Category do
    name { Faker::ProgrammingLanguage.name }
  end
end