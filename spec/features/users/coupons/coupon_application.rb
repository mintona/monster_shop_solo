require 'rails_helper'

RSpec.describe "As a in user" do
  # test for visitor?
  describe "when I have added items to my cart and visit the cart show page" do
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
    end

    it "I see a box where I can enter my coupon code" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit cart_path

      find_field "Code"
      have_button 'Submit'
    end

    it "if I enter a valid coupon code and click submit I am alerted that coupon is now applied to my order" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

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

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

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

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit cart_path

      within "#apply-coupon" do
        fill_in "Code", with: store_2_coupon.code
        click_button 'Submit'
      end

      expect(page).to have_button 'Submit'
      expect(page).to have_content "Coupon cannot be applied to your items. Please add items from #{store_2_coupon.merchant.name} and re-enter code or try another code."
    end

    it "I am alerted if I enter an invalid coupon code" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit cart_path

      within "#apply-coupon" do
        fill_in "Code", with: "INVALID CODE"
        click_button 'Submit'
      end

      expect(page).to have_button 'Submit'
      expect(page).to have_content("The coupon code you have entered does not exist. Please try again.")
    end

#TEST FOR LOGGING OUT AND NOT COMING BACK TO A COUPON ALREADY LOGGED IN.

    describe "and I have already entered and submitted a coupon code" do
      it "I can enter a new coupon which will replace the one I entered previously" do
        coupon_2 = create(:coupon, percent: 30, merchant: @store_1)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

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

        within "#apply-coupon" do
          fill_in "Code", with: coupon_2.code
          click_button 'Submit'
        end

        expect(page).to have_content("Total: $27.00")
        expect(page).to have_content("Discounted Total: $18.90")
        expect(page).to have_content("Coupon Applied: #{coupon_2.code}")

        expect(page).to_not have_content("Discounted Total: $21.60")
        expect(page).to_not have_content("Coupon Applied: #{@coupon_1.code}")
      end
    end

    it "the coupon code I entered is remembered and applied to new items if I leave the cart page, continue shopping, and re-visit the cart" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit cart_path

      expect(page).to have_content("Total: $27.00")

      within "#apply-coupon" do
        fill_in "Code", with: @coupon_1.code
        click_button 'Submit'
      end

      expect(page).to have_content("Total: $27.00")
      expect(page).to have_content("Discounted Total: $21.60")
      expect(page).to have_content("Coupon Applied: #{@coupon_1.code}")

      click_on "All Items"
      click_on "#{@item_1.name}"
      click_on "Add To Cart"
      click_on "Cart: 4"

      expect(page).to have_content("Total: $36.00")
      expect(page).to have_content("Discounted Total: $28.80")
      expect(page).to have_content("Coupon Applied: #{@coupon_1.code}")
    end

    it "my coupon code I entered is not remembered when I log out and log back in" do
      visit cart_path

      expect(page).to have_content("Total: $27.00")

      click_link "Login"

      fill_in "Email", with: @user.email
      fill_in "Password", with: "password"
      click_button 'Submit'

      visit cart_path

      within "#apply-coupon" do
        fill_in "Code", with: @coupon_1.code
        click_button 'Submit'
      end

      expect(page).to have_content("#{@coupon_1.code} has been applied to your order.")

      click_link 'Log Out'

      click_link "Login"
      fill_in "Email", with: @user.email
      fill_in "Password", with: "password"
      click_button 'Submit'

      visit cart_path

      expect(page).to have_content("Cart is currently empty")

      items = [@item_1, @item_2, @item_3]

      items.each do |item|
        visit "/items/#{item.id}"
        click_on "Add To Cart"
      end

      visit cart_path
      expect(page).to_not have_content("#{@coupon_1.code} has been applied to your order.")
    end
  end

  describe "when I have no items in my cart" do
    it "I cannot enter a coupon code" do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit cart_path

      expect(page).to_not have_field("Code")
      expect(page).to_not have_button("Submit")
    end
  end
end
