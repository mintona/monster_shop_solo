require 'rails_helper'

RSpec.describe "As a merchant" do
  describe "when I view a coupon's show page" do
    before :each do
      store = create(:merchant)
      @merchant = create(:user, role: 1, merchant: store)
      @coupon_1 = create(:coupon, merchant: store)
      @coupon_2 = create(:coupon, merchant: store)
      @coupon_3 = create(:coupon, merchant: store)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      visit merchant_coupons_path
    end

    it "I see the coupons info" do
      within "#coupon-#{@coupon_1.id}" do
        click_link @coupon_1.name
      end

      expect(current_path).to eq(merchant_coupon_path(@coupon_1.id))

      expect(page).to have_content(@coupon_1.name)
      expect(page).to have_content(@coupon_1.code)
      expect(page).to have_content(((@coupon_1.percent) * 100).to_i)
    end
  end
end
