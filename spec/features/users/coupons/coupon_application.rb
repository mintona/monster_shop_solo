require 'rails_helper'

RSpec.describe "As a in user" do
  # test for visitor?
  describe "when I have added items to my cart and go to the cart show page" do
    before :each do
      @user = create(:user)

      store = create(:merchant)
      @merchant = create(:user, role: 1, merchant: store)

      @coupon_1 = create(:coupon, percent: 20, merchant: store)

      # @order = create(:order, user: @user)

      @item_1 = create(:item, inventory: 20)
      @item_2 = create(:item, inventory: 25)
      @item_3 = create(:item, inventory: 30)

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

    it "I enter my coupon code, click submit and am alerted that coupon is now applied to my order" do
      visit cart_path

      expect(page).to have_content("Total: $27.00")

      within "#apply-coupon" do
        fill_in "Code", with: @coupon_1.code
        click_button 'Submit'
      end

      expect(current_path).to eq(cart_path)
      expect(page).to have_content("#{@coupon_1.code} has been applied to your order.")
      expect(page).to have_content("Discounted Total: $14.40")
      expect(page).to have_content("Coupon Applied: #{@coupon_1.code}")
    end

    xit "The coupon code I enter is only applied to that merchant's items" do

    end

    describe "and I have already entered and submitted a coupon code" do
      xit "I can enter a new coupon which will replace the one I entered previously" do

      end
    end
  end
end
