require 'rails_helper'

RSpec.describe "As a merchant I can create a new coupon" do
  describe "when I visit the coupon index page" do
    before :each do
      @store = create(:merchant)
      @merchant = create(:user, role: 1, merchant: @store)

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

    describe "and click the link to Create New coupon" do
      it "I can add a new coupon if I have less than 5 coupons by filling out the form entirely" do
        name = "Winter Blowout"
        code = "WINTER 2020"
        percent = 30

        visit merchant_coupons_path

        expect(page).to_not have_link(name)
        expect(page).to_not have_content(code)
        expect(page).to_not have_content(percent)

        click_link "Create New Coupon"

        fill_in "Name", with: name
        fill_in "Code", with: code
        fill_in "Percent", with: percent

        click_button 'Create Coupon'

        coupon = Coupon.last

        expect(current_path).to eq(merchant_coupons_path)
        expect(page).to have_content("Coupon has been added!")
        expect(page).to_not have_content("You already have 5 coupons. You must delete a coupon and try again.")


        within "#coupon-#{coupon.id}" do
          expect(page).to have_link(name)
          expect(page).to have_content(code)
          expect(page).to have_content("#{percent}%")
        end
      end

      it "I am alerted if I leave a required field blank and can try again with my original inputs pre-populated" do
        name = ""
        code = "WINTER 2020"
        percent = 30

        visit new_merchant_coupon_path

        fill_in "Name", with: name
        fill_in "Code", with: code
        fill_in "Percent", with: percent

        click_button 'Create Coupon'

        expect(find_field('Name').value).to eq(name)
        expect(find_field('Code').value).to eq(code)
        expect(find_field('Percent').value).to eq("#{percent}")

        expect(page).to have_button("Create Coupon")
        expect(page).to have_content("Name can't be blank. Please try again.")
      end

      it "I am alerted if I try to enter anything except number in the percent field" do
        # is this really necessary if it's  a form_for number field that actally will NOT let you type a letter in the browser?
        name = "Winter Blowout"
        code = "WINTER 2020"
        percent = "thirty"

        visit new_merchant_coupon_path

        fill_in "Name", with: name
        fill_in "Code", with: code
        fill_in "Percent", with: percent

        click_button 'Create Coupon'

        expect(find_field('Name').value).to eq(name)
        expect(find_field('Code').value).to eq(code)

        expect(page).to have_button("Create Coupon")
        expect(page).to have_content("Percent is not a number. Please try again.")
      end

      it "I am alerted if the coupon name is already in use by any merchant" do
        store_2 = create(:merchant)

        coupon_1 = Coupon.create!(name: "Winter Blowout",
                                  code: "WINTER 2020",
                                  percent: 50,
                                  merchant: @store)

        coupon_2 = Coupon.create!(name: "Winter Blowout Store 2",
                                  code: "WINTER",
                                  percent: 50,
                                  merchant: store_2)
        name = "Winter Blowout"
        code = "WINTER SALE"
        percent = 50

        visit new_merchant_coupon_path

        fill_in "Name", with: name
        fill_in "Code", with: code
        fill_in "Percent", with: percent

        click_button 'Create Coupon'

        expect(page).to have_button("Create Coupon")
        expect(page).to have_content("Name has already been taken. Please try again.")

        fill_in "Name", with: coupon_2.name

        click_button 'Create Coupon'

        expect(page).to have_button("Create Coupon")
        expect(page).to have_content("Name has already been taken. Please try again.")
      end

      it "I am alerted if the coupon code is already in use by any merchant" do
        store_2 = create(:merchant)

        coupon_1 = Coupon.create!(name: "Winter Blowout",
                                  code: "WINTER 2020",
                                  percent: 50,
                                  merchant: @store)

        coupon_2 = Coupon.create!(name: "Winter Blowout Store 2",
                                  code: "WINTER",
                                  percent: 50,
                                  merchant: store_2)
        name = "My Store's Sale"
        code = "WINTER 2020"
        percent = 50

        visit new_merchant_coupon_path

        fill_in "Name", with: name
        fill_in "Code", with: code
        fill_in "Percent", with: percent

        click_button 'Create Coupon'

        expect(page).to have_button("Create Coupon")
        expect(page).to have_content("Code has already been taken. Please try again.")

        fill_in "Name", with: coupon_2.code

        click_button 'Create Coupon'

        expect(page).to have_button("Create Coupon")
        expect(page).to have_content("Code has already been taken. Please try again.")
      end

      it "Percent must be greater than 0 and less than 100" do
        name = "Winter Sale"
        code = "WINTER 2020"
        percent = 0

        visit new_merchant_coupon_path

        fill_in "Name", with: name
        fill_in "Code", with: code
        fill_in "Percent", with: percent

        click_button 'Create Coupon'

        expect(page).to have_button("Create Coupon")
        expect(page).to have_content("Percent must be greater than 0. Please try again.")

        fill_in "Percent", with: 101

        click_button 'Create Coupon'

        expect(page).to have_button("Create Coupon")
        expect(page).to have_content("Percent must be less than or equal to 100. Please try again.")
      end

      describe "I can only have 5 coupons in the system" do
        it "alerts me if I try to add more than 5 coupons" do
        coupon_1 = Coupon.create!(name: "Winter Blowout",
                                  code: "WINTER 2020",
                                  percent: 50,
                                  merchant: @store)

        coupon_2 = Coupon.create!(name: "Spring Sale",
                                  code: "SPRING",
                                  percent: 50,
                                  merchant: @store)

        coupon_3 = Coupon.create!(name: "Summer Sale ",
                                  code: "SUMMER  2020",
                                  percent: 50,
                                  merchant: @store)

        coupon_4 = Coupon.create!(name: "Fall Sale",
                                  code: "FALL 2020 ",
                                  percent: 50,
                                  merchant: @store)

        coupon_5 = Coupon.create!(name: "Labor Day Sale",
                                  code: "LABORDAY 2020",
                                  percent: 50,
                                  merchant: @store)

        visit new_merchant_coupon_path

        fill_in "Name", with: "Newest Coupon"
        fill_in "Code", with: "Newest Code"
        fill_in "Percent", with: 20

        click_button 'Create Coupon'

        expect(page).to have_content("You already have 5 coupons. You must delete a coupon and try again.")
        expect(page).to have_button('Create Coupon')
      end
    end
    end
  end
end
