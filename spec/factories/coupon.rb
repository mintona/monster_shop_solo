FactoryBot.define do
  factory :coupon do
    sequence(:name) { |n| "Coupon Name #{n}"}
    sequence(:code) { |n| "CODE #{n}"}
    sequence(:percent, 20) { |n| n }
    merchant
  end
end
