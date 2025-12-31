require 'rails_helper'

RSpec.describe Province, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_numericality_of(:gst).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(1) }
    it { should validate_numericality_of(:pst).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(1) }
    it { should validate_numericality_of(:hst).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(1) }
  end

  describe "#total_tax_rate" do
    it "returns the sum of gst, pst, and hst" do
      province = build(:province, gst: 0.05, pst: 0.07, hst: 0.0)
      expect(province.total_tax_rate).to eq(0.12)
    end
  end
end
