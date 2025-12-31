# db/seeds.rb
require 'faker'

# --- Categories ---
categories = [ "VPNs", "Password Managers", "Hardware Keys", "Secure Routers" ]
categories.each { |c| Category.find_or_create_by!(name: c) }

# --- Products (sample per category) ---
Category.all.each do |cat|
  5.times do
    Product.find_or_create_by!(
      name: "#{cat.name} #{Faker::Company.unique.name}",
      category: cat
    ) do |p|
      p.description = Faker::Lorem.paragraph
      p.price = rand(20..200)
      p.stock_quantity = rand(10..50)
    end
  end
end

# --- Users ---
10.times do
  email = Faker::Internet.unique.email
  User.find_or_create_by!(email: email) do |u|
    u.name = Faker::Name.name
    u.address = Faker::Address.full_address
    u.password = "password"
  end
end

# --- Reviews ---
Review.delete_all
Product.find_each do |product|
  rand(1..3).times do
    Review.create!(
      user: User.all.sample,
      product: product,
      rating: rand(1..5),
      comment: Faker::Lorem.sentence
    )
  end
end

# --- Special users/products ---
User.find_or_create_by!(email: "test@example.com") do |u|
  u.name = "Test User"
  u.address = "123 Test Lane"
  u.password = "password"
end

User.find_or_create_by!(email: "admin@example.com") do |u|
  u.name = "Admin User"
  u.address = "123 Admin Lane"
  u.password = "password"
  u.admin = true
end

Product.find_or_create_by!(
  name: "Limited Edition VPN Box",
  category: Category.find_by(name: "VPNs")
) do |p|
  p.description = "Only 1 left in stock!"
  p.price = 99.99
  p.stock_quantity = 1
end

Product.find_or_create_by!(
  name: "Sold Out Router",
  category: Category.find_by(name: "Secure Routers")
) do |p|
  p.description = "Unavailable for now"
  p.price = 149.99
  p.stock_quantity = 0
end

# --- Pages ---
Page.find_or_create_by!(slug: "about") do |p|
  p.title = "About Us"
  p.content = "Write about your store..."
end
Page.find_or_create_by!(slug: "contact") do |p|
  p.title = "Contact"
  p.content = "How customers reach you..."
end

# --- Extra categories/products ---
extra_categories = %w[Electronics Books Apparel Home].map do |name|
  Category.find_or_create_by!(name: name)
end

100.times do
  cat = extra_categories.sample
  Product.find_or_create_by!(name: Faker::Commerce.unique.product_name) do |p|
    p.description = Faker::Lorem.paragraph(sentence_count: 4)
    p.price = Faker::Commerce.price(range: 5.0..200.0)
    p.stock_quantity = rand(0..50)
    p.category = cat
  end
end

# --- Provinces ---
[
  { name: "Alberta", gst: 0.05, pst: 0.0, hst: 0.0 },
  { name: "British Columbia", gst: 0.05, pst: 0.07, hst: 0.0 },
  { name: "Manitoba", gst: 0.05, pst: 0.07, hst: 0.0 },
  { name: "Ontario", gst: 0.0, pst: 0.0, hst: 0.13 },
  { name: "Quebec", gst: 0.05, pst: 0.09975, hst: 0.0 },
  { name: "Saskatchewan", gst: 0.05, pst: 0.06, hst: 0.0 },
  { name: "Nova Scotia", gst: 0.0, pst: 0.0, hst: 0.15 },
  { name: "New Brunswick", gst: 0.0, pst: 0.0, hst: 0.15 },
  { name: "Newfoundland and Labrador", gst: 0.0, pst: 0.0, hst: 0.15 },
  { name: "Prince Edward Island", gst: 0.0, pst: 0.0, hst: 0.15 },
  { name: "Northwest Territories", gst: 0.05, pst: 0.0, hst: 0.0 },
  { name: "Nunavut", gst: 0.05, pst: 0.0, hst: 0.0 },
  { name: "Yukon", gst: 0.05, pst: 0.0, hst: 0.0 }
].each do |p|
  Province.find_or_create_by!(name: p[:name]) do |prov|
    prov.gst = p[:gst]
    prov.pst = p[:pst]
    prov.hst = p[:hst]
  end
end

# --- Assign provinces to users ---
provinces = Province.all
User.where(province_id: nil).find_each do |u|
  u.update!(province: provinces.sample)
end
