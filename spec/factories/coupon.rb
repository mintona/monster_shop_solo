FactoryBot.define do
  factory :coupon do
    sequence(:name) { |n| "Coupon Name #{n}"}
    sequence(:code) { |n| "CODE #{n}"}
    percent { 0.2 }
    merchant
  end
end
