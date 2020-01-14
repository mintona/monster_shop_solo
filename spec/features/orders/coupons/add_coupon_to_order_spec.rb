require 'rails_helper'

RSpec.describe "As a in user" do
  describe "after I have applied a coupon to my order" do
    describe "I click the order link" do
      before :each do
        @user = create(:user)

        @store_1 = create(:merchant)
        @coupon_1 = create(:coupon, percent: 20, merchant: @store_1)

        @item_1 = create(:item, inventory: 20, price: 9, merchant: @store_1)
        @item_2 = create(:item, inventory: 25, price: 9, merchant: @store_1)
        @item_3 = create(:item, inventory: 30, price: 9, merchant: @store_1)

        items = [@item_1, @item_2, @item_3]

        items.each do |item|
          visit "/items/#{item.id}"
          click_on "Add To Cart"
        end

        @order = create(:order, user: @user)
        @order.item_orders.create(item: @item_1, quantity: 10, price: @item_1.price)
        @order.item_orders.create(item: @item_2, quantity: 10, price: @item_2.price)
        @order.item_orders.create(item: @item_3, quantity: 10, price: @item_3.price)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
      end

      it "I see the coupon to be applied to my order with the discounted total" do
        visit orders_new_path

        expect(page).to have_content("Total: $27.00")
        expect(page).to have_content("Discounted Total: $21.60")
        expect(page).to have_content("Coupon Applied: #{@coupon_1.code}")
      end
    end
  end
end 
