require 'rails_helper'

RSpec.describe "As a merchant" do
  describe "when I visit my coupon index page from my dashboard" do
    before :each do
      store = create(:merchant)
      @merchant = create(:user, role: 1, merchant: store)
      @coupon_1 = create(:coupon, merchant: store)
      @coupon_2 = create(:coupon, merchant: store)
      @coupon_3 = create(:coupon, merchant: store)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      visit merchant_path
    end

    it "I see a list of all my coupons and their details" do

      click_link "View Your Coupons"

      expect(current_path).to eq(merchant_coupons_path)

      within "#coupon-#{@coupon_1.id}" do
        expect(page).to have_link(@coupon_1.name)
        expect(page).to have_content(@coupon_1.code)
        expect(page).to have_content(((@coupon_1.percent) * 100).to_i)
      end

      within "#coupon-#{@coupon_2.id}" do
        expect(page).to have_link(@coupon_2.name)
        expect(page).to have_content(@coupon_2.code)
        expect(page).to have_content(((@coupon_2.percent) * 100).to_i)

      end

      within "#coupon-#{@coupon_3.id}" do
        expect(page).to have_link(@coupon_3.name)
        expect(page).to have_content(@coupon_3.code)
        expect(page).to have_content(((@coupon_3.percent) * 100).to_i)
      end
    end

    it "I do not see coupons that do not belong to my store" do
      store_2 = create(:merchant)

      coupon_4 = create(:coupon, merchant: store_2, percent: 0.6)

      visit merchant_coupons_path

      expect(page).to_not have_css("#coupon-#{coupon_4.id}")
      expect(page).to_not have_link(coupon_4.name)
      expect(page).to_not have_content(coupon_4.code)
      # expect(page).to_not have_content(coupon_4.percent)
      expect(page).to_not have_content((coupon_4.percent * 100).to_i)
    end

    describe "if I have no coupons" do
      it "I see text alerting me I have no coupons and a link to add a new coupon" do
        store_2 = create(:merchant)
        merchant_2 = create(:user, role: 1, merchant: store_2)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant_2)

        visit merchant_coupons_path

        expect(page).to have_content("You have not added any coupons yet.")

        expect(page).to have_link("Create New Coupon")
      end
    end
  end
end
