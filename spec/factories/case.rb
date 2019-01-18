FactoryBot.define do
  factory :case, class: Hackney::Income::Models::Case do
    tenancy_ref Faker::Lorem.characters(5)
  end
end
