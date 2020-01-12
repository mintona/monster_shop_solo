require 'rails_helper'

RSpec.describe "As a merchant I can edit an existing coupon" do
  before :each do
    store = create(:merchant)
    @merchant = create(:user, role: 1, merchant: store)
    @coupon_1 = create(:coupon, merchant: store)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
  end
  
  describe "when I visit the coupon index page" do

    describe "and click the button Edit next to the coupon" do
      it "I fill out all required fields on the form to edit that coupon's information and am redirected back to the coupon index" do
        original_name = @coupon_1.name
        original_code = @coupon_1.code
        original_percent = @coupon_1.percent

        visit merchant_coupons_path

        within "#coupon-#{@coupon_1.id}" do
          expect(page).to have_link(original_name)
          expect(page).to have_content(original_code)
          expect(page).to have_content("#{original_percent}%")
          click_button 'Edit'
        end

        expect(current_path).to eq(edit_merchant_coupon_path(@coupon_1.id))

        expect(find_field('Name').value).to eq(@coupon_1.name)
        expect(find_field('Code').value).to eq(@coupon_1.code)
        expect(find_field('Percent').value).to eq("#{@coupon_1.percent}")

        new_name = "New name"
        new_code = "New code"
        new_percent = 99

        fill_in "Name", with: new_name
        fill_in "Code", with: new_code
        fill_in "Percent", with: new_percent

        click_button 'Update Coupon'

        expect(current_path).to eq(merchant_coupons_path)
        expect(page).to have_content("Coupon has been updated!")

        within "#coupon-#{@coupon_1.id}" do
          expect(page).to have_link(new_name)
          expect(page).to have_content(new_code)
          expect(page).to have_content("#{new_percent}%")

          expect(page).to_not have_link(original_name)
          expect(page).to_not have_content(original_code)
          expect(page).to_not have_content("#{original_percent}%")
        end
      end

      it "I am alerted if I leave a required field blank and can try again with my original inputs pre-populated" do
        new_name = ""
        new_code = ""
        new_percent = ""

        visit edit_merchant_coupon_path(@coupon_1.id)

        fill_in "Name", with: new_name
        fill_in "Code", with: new_code
        fill_in "Percent", with: new_percent

        click_button 'Update Coupon'
#these are pre populated with whatever you tried to answer even if it wasn't acceptable...
        expect(find_field('Name').value).to eq(new_name)
        expect(find_field('Code').value).to eq(new_code)
        expect(find_field('Percent').value).to eq("#{new_code}")

        expect(page).to have_button("Update Coupon")
        expect(page).to have_content("Name can't be blank, Code can't be blank, Percent can't be blank, and Percent is not a number. Please try again.")
      end

      it "I am alerted if I try to enter anything except number in the percent field" do
        # is this really necessary if it's  a form_for number field that actally will NOT let you type a letter in the browser?
        new_percent = "thirty"

        visit edit_merchant_coupon_path(@coupon_1.id)

        fill_in "Percent", with: new_percent

        click_button 'Update Coupon'

        expect(page).to have_button("Update Coupon")
        expect(page).to have_content("Percent is not a number. Please try again.")
      end

      it "I am alerted if the coupon name is already in use by any merchant" do
        store_2 = create(:merchant)

        coupon_2 = Coupon.create!(name: "Winter Blowout Store 2",
                                  code: "WINTER",
                                  percent: 50,
                                  merchant: store_2)

        visit edit_merchant_coupon_path(@coupon_1.id)

        fill_in "Name", with: coupon_2.name

        click_button 'Update Coupon'

        expect(page).to have_button("Update Coupon")
        expect(page).to have_content("Name has already been taken. Please try again.")
      end

      it "I am alerted if the coupon code is already in use by any merchant" do
        store_2 = create(:merchant)

        coupon_2 = Coupon.create!(name: "Winter Blowout Store 2",
                                  code: "WINTER",
                                  percent: 50,
                                  merchant: store_2)

        visit edit_merchant_coupon_path(@coupon_1.id)

        fill_in "Code", with: coupon_2.code

        click_button 'Update Coupon'
      end

      it "Percent must be greater than 0 and less than 100" do
        visit edit_merchant_coupon_path(@coupon_1.id)

        fill_in "Percent", with: 0

        click_button 'Update Coupon'

        expect(page).to have_button("Update Coupon")
        expect(page).to have_content("Percent must be greater than 0. Please try again.")

        fill_in "Percent", with: 101

        click_button 'Update Coupon'

        expect(page).to have_button("Update Coupon")
        expect(page).to have_content("Percent must be less than or equal to 100. Please try again.")
      end
    end
  end

  describe "when I am on a coupon's show page" do
    describe "I click the edit button" do
      it "I fill out all required fields on the form to edit that coupon's information and am redirected back to the coupon's show page" do
        original_name = @coupon_1.name
        original_code = @coupon_1.code
        original_percent = @coupon_1.percent

        visit merchant_coupon_path(@coupon_1.id)

        click_button 'Edit'

        new_name = "New name"
        new_code = "New code"
        new_percent = 99

        fill_in "Name", with: new_name
        fill_in "Code", with: new_code
        fill_in "Percent", with: new_percent

        click_button 'Update Coupon'

        expect(current_path).to eq(merchant_coupon_path(@coupon_1.id))
        expect(page).to have_content("Coupon has been updated!")

        expect(page).to have_content(new_name)
        expect(page).to have_content(new_code)
        expect(page).to have_content("#{new_percent}%")

        expect(page).to_not have_content(original_name)
        expect(page).to_not have_content(original_code)
        expect(page).to_not have_content("#{original_percent}%")
      end
    end
  end


end