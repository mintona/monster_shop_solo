require 'rails_helper'

RSpec.describe "As a merchant" do
  describe "when I visit the coupon index page" do
    before :each do
      @store = create(:merchant)
      @merchant = create(:user, role: 1, merchant: @store)
      # @coupon_1 = create(:coupon, merchant: store)
      # @coupon_2 = create(:coupon, merchant: store)
      # @coupon_3 = create(:coupon, merchant: store)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

    end


    it "I see a link to add a new coupon if I don't have any coupons yet" do
      visit merchant_coupons_path

      expect(page).to have_link("Create New Coupon")
    end

    it "I see a link to add a new coupon for my shop if I already have coupons" do
      coupon_1 = create(:coupon, merchant: @store)
      coupon_2 = create(:coupon, merchant: @store)
      coupon_3 = create(:coupon, merchant: @store)

      visit merchant_coupons_path

      expect(page).to have_link("Create New Coupon")
    end

    it "I can add a new coupon by filling out the form" do
      name = "Winter Blowout"
      code = "WINTER 2020"
      percent = 0.3

      visit merchant_coupons_path

      expect(page).to_not have_link(name)
      expect(page).to have_content(code)
      expect(page).to have_content((percent * 100).to_i)

      click_link "Create New Coupon"

      fill_in "Name", with: name
      fill_in "Code", with: code
      fill_in "Percent", with: percent

      click_button 'Submit'

      coupon = Coupon.last

      expect(current_path).to eq(merchant_coupon_path)

      within "#coupon-#{coupon.id}" do
        expect(page).to have_link(name)
        expect(page).to have_content(code)
        expect(page).to have_content((percent * 100).to_i)
      end
    end

    xit "I am alerted if I do not fill out the form correctly" do

    end
  end
end
