require "rails_helper"

RSpec.describe "Products display", type: :request do
  let!(:category) { create(:category, name: "VPNs") }
  let!(:p1) { create(:product, name: "Alpha VPN", description: "Fast and secure", price: 10, stock_quantity: 5, category: category) }
  let!(:p2) { create(:product, name: "Bravo Router", description: "Secure router", price: 20, stock_quantity: 3, category: category) }

  describe "GET /products" do
    it "searches by keyword" do
      get products_path, params: { search: "Alpha" }
      expect(response.body).to include("Alpha VPN")
      expect(response.body).not_to include("Bravo Router")
    end

    it "filters on sale" do
      p1.update!(on_sale: true)
      get products_path, params: { filter: "on_sale" }
      expect(response.body).to include("Alpha VPN")
      expect(response.body).not_to include("Bravo Router")
    end

    it "filters new products" do
      p2.update!(is_new: true)
      get products_path, params: { filter: "new" }
      expect(response.body).to include("Bravo Router")
      expect(response.body).not_to include("Alpha VPN")
    end

    it "filters recently updated products" do
      p1.update!(recently_updated: true)
      get products_path, params: { filter: "recently_updated" }
      expect(response.body).to include("Alpha VPN")
      expect(response.body).not_to include("Bravo Router")
    end

    it "shows empty state when no products match" do
      get products_path, params: { search: "Nonexistent" }
      expect(response.body).to include("No products found")
    end
  end
end
