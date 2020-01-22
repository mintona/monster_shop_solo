require 'rails_helper'

RSpec.describe "As a user" do
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

        visit cart_path
        fill_in "Code", with: @coupon_1.code
        click_button 'Submit'

        # @order = create(:order, user: @user)
        # @order.item_orders.create(item: @item_1, quantity: 10, price: @item_1.price)
        # @order.item_orders.create(item: @item_2, quantity: 10, price: @item_2.price)
        # @order.item_orders.create(item: @item_3, quantity: 10, price: @item_3.price)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
      end

      it "I see the coupon to be applied to my order with the discounted total" do
        visit new_order_path

        expect(page).to have_content("Total: $27.00")
        expect(page).to have_content("Discounted Total: $21.60")
        expect(page).to have_content("Coupon Applied: #{@coupon_1.code}, #{@coupon_1.percent}% Off")
      end

      describe "I fill in my shipping address" do
        before :each do
          visit new_order_path

          fill_in "Name", with: @user.name
          fill_in "Address", with: @user.address
          fill_in "City", with: @user.city
          fill_in "State", with: @user.state
          fill_in "Zip", with: @user.zip

          # click_button 'Create Order'
        end

        it "I click the Create Order button, the order stores the coupon, and am redirected to my orders index where I see the order and its coupon" do
          click_button 'Create Order'

          order = Order.last

          expect(order.coupon).to eq(@coupon_1)

          expect(current_path).to eq(profile_orders_path)

          within "#order-#{order.id}" do
            expect(page).to have_link(order.id)
            expect(page).to have_content("Discounted Total: $21.60")
            expect(page).to have_content("Coupon Applied: #{@coupon_1.code}, #{@coupon_1.percent}% Off")
          end
        end

        describe "After my order has been placed with a coupon" do
          describe "when I visit an order show page" do
            it "I see the coupon that was used and the discounted price" do
              click_button 'Create Order'

              order = Order.last

              visit "/profile/orders/#{order.id}"

              expect(page).to have_content("Discounted Total: $21.60")
              expect(page).to have_content("Coupon Applied: #{@coupon_1.code}, #{@coupon_1.percent}% Off")
            end
          end
        end
      end
    end
  end
end
