# frozen_string_literal: true

admin_email = ENV.fetch("ADMIN_EMAIL", "admin@carshop.local")
admin_password = ENV.fetch("ADMIN_PASSWORD", "password123")

User.find_or_create_by!(email: admin_email) do |user|
  user.name = "Admin"
  user.password = admin_password
  user.password_confirmation = admin_password
  user.role = :admin
end

ShopSetting.current.update!(
  bank_name: "ธนาคารกสิกรไทย",
  account_number: "123-4-56789-0",
  account_name: "Carshop Admin",
  payment_instructions: "โอนเงินแล้วแนบสลิปในหน้าออเดอร์ ระบบจะตรวจสอบภายใน 24 ชม."
)

categories = [
  { name: "Pokemon", description: "การ์ด Pokemon TCG", position: 1 },
  { name: "Yu-Gi-Oh!", description: "การ์ด Yu-Gi-Oh!", position: 2 },
  { name: "One Piece", description: "การ์ด One Piece TCG", position: 3 }
]

categories.each do |attrs|
  category = Category.find_or_create_by!(name: attrs[:name]) do |c|
    c.description = attrs[:description]
    c.position = attrs[:position]
  end

  product = category.products.find_or_create_by!(name: "Sample Card - #{category.name}") do |p|
    p.description = "การ์ดตัวอย่างสำหรับทดสอบระบบ"
  end

  [
    { condition: :new_condition, language: :th, price: 150, stock_quantity: 5 },
    { condition: :used, language: :en, price: 90, stock_quantity: 3 },
    { condition: :new_condition, language: :ja, price: 220, stock_quantity: 2 }
  ].each do |variant_attrs|
    product.product_variants.find_or_create_by!(
      condition: variant_attrs[:condition],
      language: variant_attrs[:language]
    ) do |variant|
      variant.price = variant_attrs[:price]
      variant.stock_quantity = variant_attrs[:stock_quantity]
    end
  end
end

puts "Seed complete!"
puts "Admin login: #{admin_email} / #{admin_password}"
