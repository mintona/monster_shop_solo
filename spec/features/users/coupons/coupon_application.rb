require 'rails_helper'

RSpec.describe "As a in user" do
  # test for visitor?
  describe "when I have added items to my cart and visit the cart show page" do
    before :each do
      @user = create(:user)

      store_1 = create(:merchant)
      # @merchant = create(:user, role: 1, merchant: store)

      @coupon_1 = create(:coupon, percent: 20, merchant: store_1)

      # @order = create(:order, user: @user)

      @item_1 = create(:item, inventory: 20, price: 9, merchant: store_1) #11
      @item_2 = create(:item, inventory: 25, price: 9, merchant: store_1) #12
      @item_3 = create(:item, inventory: 30, price: 9, merchant: store_1) #13


      items = [@item_1, @item_2, @item_3]

      items.each do |item|
        visit "/items/#{item.id}"
        click_on "Add To Cart"
      end
      # @order.item_orders.create(item: @item_1, quantity: 10, price: @item_1.price)
      # @order.item_orders.create(item: @item_2, quantity: 10, price: @item_2.price)
      # @order.item_orders.create(item: @item_3, quantity: 10, price: @item_3.price)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end
#Add test for when there are no items in the cart
    it "I see a box where I can enter my coupon code" do
      visit cart_path

      within "#apply-coupon" do
        find_field "Code"
        have_button 'Submit'
      end
    end

    it "if I enter a valid coupon code and click submit I am alerted that coupon is now applied to my order" do
      visit cart_path

      expect(page).to have_content("Total: $27.00")

      within "#apply-coupon" do
        fill_in "Code", with: @coupon_1.code
        click_button 'Submit'
      end

      expect(current_path).to eq(cart_path)
      expect(page).to have_content("#{@coupon_1.code} has been applied to your order.")

      expect(page).to have_content("Total: $27.00")
      expect(page).to have_content("Discounted Total: $21.60")
      expect(page).to have_content("Coupon Applied: #{@coupon_1.code}")
    end

    it "The coupon code I enter is only applied to that merchant's items" do
      store_2 = create(:merchant)
      @item_4 = create(:item, inventory: 20, price: 10, merchant: store_2) #14
      @item_5 = create(:item, inventory: 25, price: 10, merchant: store_2) #15
      @item_6 = create(:item, inventory: 30, price: 10, merchant: store_2) #16

      store_2_items = [@item_4, @item_5, @item_6]

      store_2_items.each do |item|
        visit "/items/#{item.id}"
        click_on "Add To Cart"
      end

      visit cart_path

      expect(page).to have_content("Total: $57.00")

      within "#apply-coupon" do
        fill_in "Code", with: @coupon_1.code
        click_button 'Submit'
      end

      expect(current_path).to eq(cart_path)
      expect(page).to have_content("#{@coupon_1.code} has been applied to your order.")

      expect(page).to have_content("Total: $57.00")
      expect(page).to have_content("Discounted Total: $51.60")
      expect(page).to have_content("Coupon Applied: #{@coupon_1.code}")
    end

    it "I am alerted if I enter a coupon code of a merchant who's items I have not added to my cart." do
      store_2 = create(:merchant)
      store_2_coupon = create(:coupon, percent: 15, merchant: store_2)

      visit cart_path

      within "#apply-coupon" do
        fill_in "Code", with: store_2_coupon.code
        click_button 'Submit'
      end

      expect(page).to have_button 'Submit'
      expect(page).to have_content "Coupon cannot be applied to your items. Please add items from #{store_2_coupon.merchant.name} and re-enter code or try another code."
    end

    it "I am alerted if I enter an invalid coupon code" do
      visit cart_path

      within "#apply-coupon" do
        fill_in "Code", with: "INVALID CODE"
        click_button 'Submit'
      end

      expect(page).to have_button 'Submit'
      expect(page).to have_content("The coupon code you have entered does not exist. Please try again.")
    end

    describe "and I have already entered and submitted a coupon code" do
      xit "I can enter a new coupon which will replace the one I entered previously" do

      end
    end
  end
end
