require 'rails_helper'

RSpec.describe "As a merchant" do
  describe "when I visit my items page" do
    before :each do
      @merchant = create(:merchant)
      @item_1 = create(:item, merchant: @merchant)
      @item_2 = create(:item, merchant: @merchant)
      @item_3 = create(:item, description: "Item 3 description", merchant: @merchant, active?: false, image: "https://cdn.shopify.com/s/files/1/0836/6919/products/thousand-helmet-rose-gold-1_2000x.jpg?v=1568244140")

      @merchant_employee = create(:user, role: 1, merchant: @merchant)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_employee)
    end

    it "I see only my items info" do
      merchant_2 = create(:merchant)
      merchant_2_item_1 = create(:item, description: "Item 2 description", image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588")

      visit merchant_items_path

      within "#item-#{@item_1.id}" do
        expect(page).to have_link(@item_1.name)
        expect(page).to have_content(@item_1.description)
        expect(page).to have_content("Price: $#{@item_1.price}")
        expect(page).to have_content("Active")
        expect(page).to have_content("Inventory: #{@item_1.inventory}")
        expect(page).to have_link(@merchant.name)
        expect(page).to have_css("img[src*='#{@item_1.image}']")
      end

      within "#item-#{@item_2.id}" do
        expect(page).to have_link(@item_2.name)
        expect(page).to have_content(@item_2.description)
        expect(page).to have_content("Price: $#{@item_2.price}")
        expect(page).to have_content("Active")
        expect(page).to have_content("Inventory: #{@item_2.inventory}")
        expect(page).to have_link(@merchant.name)
        expect(page).to have_css("img[src*='#{@item_2.image}']")
      end

      within "#item-#{@item_3.id}" do
        expect(page).to have_link(@item_3.name)
        expect(page).to have_content(@item_3.description)
        expect(page).to have_content("Price: $#{@item_3.price}")
        expect(page).to have_content("Inactive")
        expect(page).to have_content("Inventory: #{@item_3.inventory}")
        expect(page).to have_link(@merchant.name)
        expect(page).to have_css("img[src*='#{@item_3.image}']")
      end

      expect(page).to_not have_css("#item-#{merchant_2_item_1.id}")
      expect(page).to_not have_link(merchant_2_item_1.name)
      expect(page).to_not have_content(merchant_2_item_1.description)
      expect(page).to_not have_content("Price: $#{merchant_2_item_1.price}")
      expect(page).to_not have_content("Inventory: #{merchant_2_item_1.inventory}")
      expect(page).to_not have_link(merchant_2.name)
      expect(page).to_not have_css("img[src*='#{merchant_2_item_1.image}']")

      within "#item-#{@item_1.id}" do
        click_on('img')
      end

      expect(current_path).to eq("/merchant/items/#{@item_1.id}")
    end

    it "the item name and image both link to my merchant item show page" do
      visit merchant_items_path

      within "#item-#{@item_1.id}" do
        click_on('img')
      end

      expect(current_path).to eq("/merchant/items/#{@item_1.id}")

      visit merchant_items_path

      within "#item-#{@item_1.id}" do
        click_on(@item_1.name)
      end

      expect(current_path).to eq("/merchant/items/#{@item_1.id}")
    end

    it "I can click a button to deactivate the item if it is active" do
      visit merchant_items_path

      within "#item-#{@item_1.id}" do
        expect(page).to have_content("Active")
        click_button "Deactivate"
      end

      expect(current_path).to eq(merchant_items_path)
      expect(page).to have_content("#{@item_1.name} is no longer for sale.")

      within "#item-#{@item_1.id}" do
        expect(page).to have_content("Inactive")
        expect(page).to_not have_content("Active")
        expect(page).to_not have_button("Deactivate")
      end
    end

    it "I can click a button to activate the item if it is inactive" do
      visit merchant_items_path

      within "#item-#{@item_3.id}" do
        expect(page).to have_content("Inactive")
        click_button "Activate"
      end

      expect(current_path).to eq(merchant_items_path)
      expect(page).to have_content("#{@item_3.name} is available for sale.")

      within "#item-#{@item_3.id}" do
        expect(page).to have_content("Active")
        expect(page).to_not have_content("Inactive")
        expect(page).to have_button("Deactivate")
        expect(page).to_not have_button("Activate")
      end
    end

    it "I can delete an item that has never been ordered by clicking its delete button" do
      visit merchant_items_path

      within "#item-#{@item_1.id}" do
        expect(page).to have_button("Delete")
      end

      within "#item-#{@item_2.id}" do
        expect(page).to have_button("Delete")
      end

      within "#item-#{@item_3.id}" do
        click_button "Delete"
      end

      expect(current_path).to eq(merchant_items_path)
      expect(page).to have_content("#{@item_3.name} has been deleted.")

      expect(page).to_not have_css("#item-#{@item_3.id}")
      expect(page).to_not have_link(@item_3.name)
      expect(page).to_not have_content(@item_3.description)
      expect(page).to_not have_content("Price: $#{@item_3.price}")
      expect(page).to_not have_content("Inventory: #{@item_3.inventory}")
      expect(page).to_not have_css("img[src*='#{@item_3.image}']")
    end

    it "There is not a delete button for an item that has been ordered, regardles of order status" do
      order_1 = create(:order)
      order_1.item_orders.create(item: @item_1, quantity: 2, price: @item_1.price)

      order_2 = create(:order, status: 1)
      order_2.item_orders.create(item: @item_2, quantity: 2, price: @item_2.price)

      order_3 = create(:order, status: 3)
      order_3.item_orders.create(item: @item_3, quantity: 2, price: @item_3.price)

      visit merchant_items_path

      within "#item-#{@item_1.id}" do
        expect(page).to_not have_button("Delete")
      end

      within "#item-#{@item_2.id}" do
        expect(page).to_not have_button("Delete")
      end

      within "#item-#{@item_3.id}" do
        expect(page).to_not have_button("Delete")
      end
    end
  end
end
