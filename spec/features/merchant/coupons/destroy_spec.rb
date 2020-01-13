require 'rails_helper'

RSpec.describe "As a merchant" do
  describe "I can delete a coupon if it has not been applied to any orders" do
    before :each do
      store = create(:merchant)
      @merchant = create(:user, role: 1, merchant: store)
      @coupon_1 = create(:coupon, merchant: store)
      @coupon_2 = create(:coupon, merchant: store)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
    end

    it "by clicking the delete button next to the coupon from the item index page" do
      visit merchant_coupons_path

      within "#coupon-#{@coupon_1.id}" do
        expect(page).to have_link(@coupon_1.name)
        expect(page).to have_content(@coupon_1.code)
        expect(page).to have_content("#{@coupon_1.percent}%")
        expect(page).to have_button("Edit")
        expect(page).to have_button("Delete")
      end

      within "#coupon-#{@coupon_2.id}" do
        expect(page).to have_link(@coupon_2.name)
        expect(page).to have_content(@coupon_2.code)
        expect(page).to have_content("#{@coupon_2.percent}%")
        expect(page).to have_button("Edit")
        click_button("Delete")
      end

      expect(current_path).to eq(merchant_coupons_path)
      expect(page).to have_content("Coupon has been deleted.")

      expect(page).to_not have_css("#coupon-#{@coupon_2.id}")
      expect(page).to_not have_link(@coupon_2.name)
      expect(page).to_not have_content(@coupon_2.code)
      expect(page).to_not have_content("#{@coupon_2.percent}%")

      within "#coupon-#{@coupon_1.id}" do
        expect(page).to have_link(@coupon_1.name)
        expect(page).to have_content(@coupon_1.code)
        expect(page).to have_content("#{@coupon_1.percent}%")
        expect(page).to have_button("Edit")
        expect(page).to have_button("Delete")
      end
    end

    it "by clicking the delete button from the item show page" do
      visit merchant_coupons_path

      within "#coupon-#{@coupon_1.id}" do
        expect(page).to have_link(@coupon_1.name)
        expect(page).to have_content(@coupon_1.code)
        expect(page).to have_content("#{@coupon_1.percent}%")
        expect(page).to have_button("Edit")
        expect(page).to have_button("Delete")
      end

      within "#coupon-#{@coupon_2.id}" do
        expect(page).to have_link(@coupon_2.name)
        expect(page).to have_content(@coupon_2.code)
        expect(page).to have_content("#{@coupon_2.percent}%")
        expect(page).to have_button("Edit")
        expect(page).to have_button("Delete")
        click_link @coupon_2.name
      end

      expect(current_path).to eq(merchant_coupon_path(@coupon_2.id))

      click_button 'Delete'

      expect(current_path).to eq(merchant_coupons_path)

      expect(page).to_not have_css("#coupon-#{@coupon_2.id}")
      expect(page).to_not have_link(@coupon_2.name)
      expect(page).to_not have_content(@coupon_2.code)
      expect(page).to_not have_content("#{@coupon_2.percent}%")
    end
  end

  describe "I cannot delete a coupon if it has been applied to an order of any status" do
    before :each do
      store = create(:merchant)
      @merchant = create(:user, role: 1, merchant: store)

      # @user = User.last
      @order = create(:order)

      @item_1 = create(:item, inventory: 20, merchant: store)
      @item_2 = create(:item, inventory: 25, merchant: store)
      @item_3 = create(:item, inventory: 30, merchant: store)

      @order.item_orders.create(item: @item_1, quantity: 2, price: @item_1.price)
      @order.item_orders.create(item: @item_2, quantity: 1, price: @item_2.price)
      @order.item_orders.create(item: @item_3, quantity: 3, price: @item_3.price)

      @coupon_1 = create(:coupon, merchant: store)
      @coupon_2 = create(:coupon, merchant: store)

      @order.coupon = @coupon_1

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
    end

    it "there is no delete button for coupons that have been applied to an order on coupon index" do
      visit merchant_coupons_path

      within "#coupon-#{@coupon_1.id}" do
        expect(page).to_not have_button('Delete')
      end

      within "#coupon-#{@coupon_2.id}" do
        expect(page).to have_button('Delete')
      end
    end

    xit "there is no delete button on a coupon show page if it has been applied to an order" do

    end
  end
end
