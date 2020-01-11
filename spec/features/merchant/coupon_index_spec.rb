require 'rails_helper'

RSpec.describe "As a merchant" do
  describe "when I visit my coupon index page" do
    before :each do
      @merchant = create(:user, role: 1)
      @coupon_1 = create(:coupon)
      @coupon_2 = create(:coupon)
      @coupon_3 = create(:coupon)
    end

    it "I see a list of all my coupons and their details" do
      visit merchant_dashboard_path

      click_link "My Coupons"

      expect(current_path).to eq(merchant_coupons_path)

      within "#coupon-#{@coupon_1.id}" do
        expect(page).to have_link(@coupon_1.name)
        expect(page).to have_content(@coupon_1.code)
        expect(page).to have_content(@coupon_1.percent)
      end

      within "#coupon-#{@coupon_3.id}" do
        expect(page).to have_link(@coupon_2.name)
        expect(page).to have_content(@coupon_2.code)
        expect(page).to have_content(@coupon_2.percent)
      end

      within "#coupon-#{@coupon_3.id}" do
        expect(page).to have_link(@coupon_3.name)
        expect(page).to have_content(@coupon_3.code)
        expect(page).to have_content(@coupon_3.percent)
      end
    end
  end
end
