FactoryBot.define do
  factory :user, class: Hackney::Rent::Models::User, aliases: [:assigned_user] do
    role { :base_user }

    trait :credit_controller do
      role { :credit_controller }
    end

    trait :legal_case_worker do
      role { :legal_case_worker }
    end
  end
end
