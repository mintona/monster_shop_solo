require 'rails_helper'

RSpec.describe Coupon do
  describe "validations" do
    it {should validate_presence_of :name}
    it {should validate_presence_of :code}
    it {should validate_presence_of :percent}
  end

  describe "relationships" do
    it {should belong_to :merchant}
    it {should belong_to(:order).optional}
  end
end
