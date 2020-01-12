require 'rails_helper'

RSpec.describe "As a merchant" do
  describe "I can edit a coupon's information" do
    before :each do
      store = create(:merchant)
      @merchant = create(:user, role: 1, merchant: store)
      @coupon_1 = create(:coupon, merchant: store)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
    end

    describe "from the coupon index page" do
      describe "by clicking the edit button next to the coupon" do
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

          within "#coupon-#{@coupon_1.id}" do
            expect(page).to have_link(new_name)
            expect(page).to have_content(new_code)
            expect(page).to have_content("#{new_percent}%")

            expect(page).to_not have_link(original_name)
            expect(page).to_not have_content(original_code)
            expect(page).to_not have_content("#{original_percent}%")
          end
        end
      end
    end

    describe "from the coupon show page" do
      describe "by clicking the edit link" do
        xit "I fill out the form to edit that coupon's information and am redirected back to the coupon show page" do

        end
      end
    end

  end
end
