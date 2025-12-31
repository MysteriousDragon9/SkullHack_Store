FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password" }
    admin { false }

    trait :admin do
      admin { true }
    end

    trait :confirmed do
      confirmed_at { Time.current }
    end

    trait :with_cart do
      after(:create) do |user|
        create(:cart, user: user)
      end
    end

    factory :user_with_orders do
      transient do
        orders_count { 3 }
      end

      after(:create) do |user, evaluator|
        create_list(:order, evaluator.orders_count, user: user)
      end
    end
  end
end
