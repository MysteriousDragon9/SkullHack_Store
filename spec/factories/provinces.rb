FactoryBot.define do
  factory :province do
    sequence(:name) { |n| "Province #{n}" }
    gst { 0.05 }
    pst { 0.07 }
    hst { 0.0 }

    trait :gst_only do
      gst { 0.05 }
      pst { 0.0 }
      hst { 0.0 }
    end

    trait :hst_only do
      gst { 0.0 }
      pst { 0.0 }
      hst { 0.13 }
    end

    trait :gst_pst do
      gst { 0.05 }
      pst { 0.07 }
      hst { 0.0 }
    end

    factory :manitoba do
      name { "Manitoba" }
      gst { 0.05 }
      pst { 0.07 }
      hst { 0.0 }
    end

    factory :ontario do
      name { "Ontario" }
      gst { 0.0 }
      pst { 0.0 }
      hst { 0.13 }
    end
  end
end
