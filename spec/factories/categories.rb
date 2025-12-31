FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }

    trait :featured do
      featured { true }
    end

    trait :hidden do
      hidden { true }
    end

    factory :category_with_products do
      transient do
        products_count { 3 }
      end

      after(:create) do |category, evaluator|
        create_list(:product, evaluator.products_count, category: category)
      end
    end
  end
end
