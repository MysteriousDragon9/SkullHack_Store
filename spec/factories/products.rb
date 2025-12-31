FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    description { Faker::Commerce.product_name }
    price { Faker::Commerce.price(range: 5..100.0) }
    stock_quantity { 10 }
    association :category

    trait :on_sale do
      on_sale { true }
      sale_price { price * 0.8 }
    end

    trait :new do
      is_new { true }
    end

    trait :out_of_stock do
      stock_quantity { 0 }
    end

    trait :recently_updated do
      recently_updated { true }
    end

    factory :product_with_reviews do
      transient do
        reviews_count { 3 }
      end

      after(:create) do |product, evaluator|
        create_list(:review, evaluator.reviews_count, product: product)
      end
    end
  end
end
