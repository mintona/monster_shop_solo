require 'rails_helper'

RSpec.describe Coupon do
  describe "validations" do
    it {should validate_presence_of :name}
    it {should validate_uniqueness_of :name}

    it {should validate_presence_of :code}
    it {should validate_uniqueness_of :code}

    it {should validate_presence_of :percent}
    it {should validate_numericality_of(:percent).is_greater_than(0)}
    it {should validate_numericality_of(:percent).is_less_than_or_equal_to(100)}

  end

  describe "relationships" do
    it {should belong_to :merchant}
    it {should have_many :orders}
  end

  describe "attributes" do
    it "has attributes" do
      merchant = create(:merchant)
      coupon = Coupon.create!(name: "Winter Sale",
                              code: "WINTER 2020",
                              percent: 30,
                              merchant: merchant)

      expect(coupon.name).to eq("Winter Sale")
      expect(coupon.code).to eq("WINTER 2020")
      expect(coupon.percent).to eq(30)
    end
  end

  describe "model methods" do
    describe "#never_applied?" do
      it "returns true if a coupon has not been applied to an order" do
        store = create(:merchant)
        coupon_1 = create(:coupon, merchant: store)
        coupon_2 = create(:coupon, merchant: store)

        item_1 = create(:item, inventory: 20, merchant: store)

        order = create(:order)

        order.item_orders.create(item: item_1, quantity: 2, price: item_1.price)

        coupon_1.orders << order

        expect(coupon_1.never_applied?).to eq(false)
        expect(coupon_2.never_applied?).to eq(true)
      end
    end

    describe "#deactivate" do
      it "changes a coupons status from active? = true to active? = false" do
        coupon_1 = create(:coupon)

        coupon_1.deactivate

        expect(coupon_1.active?).to eq(false)
      end
    end

    describe "#activate" do
      it "changes a coupons status from active? = false to active? = true" do
        coupon_1 = create(:coupon)

        coupon_1.update!(active?: false)

        coupon_1.activate

        expect(coupon_1.active?).to eq(true)
      end
    end

    describe "#status" do
      it "returns the coupons status" do
        coupon_1 = create(:coupon)
        coupon_2 = create(:coupon, active?: false)

        expect(coupon_1.status).to eq("Active")
        expect(coupon_2.status).to eq("Inactive")
      end
    end
  end
end
