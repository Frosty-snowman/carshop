# frozen_string_literal: true
# Pre-order feature seed data - idempotent and safe to rerun

puts "🎴 Seeding pre-order data..."

# Create customer users for testing
customers = [
  { email: "customer1@test.local", name: "สมชาย ใจดี", password: "customer123" },
  { email: "customer2@test.local", name: "สมหญิง มีสุข", password: "customer123" },
  { email: "customer3@test.local", name: "วิชัย รักการ์ด", password: "customer123" }
]

customer_users = customers.map do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |user|
    user.name = attrs[:name]
    user.password = attrs[:password]
    user.password_confirmation = attrs[:password]
    user.role = :customer
  end
end

# Create categories for TCG products
tcg_categories = [
  { name: "Lorcana", description: "Disney Lorcana TCG - เกมการ์ดดิสนีย์", position: 4 },
  { name: "Pokemon Preorder", description: "Pokemon TCG พรีออเดอร์", position: 5 }
]

tcg_categories.each do |attrs|
  Category.find_or_create_by!(name: attrs[:name]) do |c|
    c.description = attrs[:description]
    c.position = attrs[:position]
  end
end

lorcana_cat = Category.find_by!(name: "Lorcana")
pokemon_cat = Category.find_by!(name: "Pokemon Preorder")
one_piece_cat = Category.find_by!(name: "One Piece")

# Pre-order products with various states
preorder_products = [
  {
    name: "Lorcana: Into the Inklands Booster Box (TH)",
    description: "บูสเตอร์บ็อกซ์ชุด Into the Inklands ภาษาไทย 24 แพ็ค\nวางจำหน่าย มีนาคม 2027",
    category: lorcana_cat,
    variants: [
      {
        condition: :new_condition,
        language: :th,
        price: 3500,
        stock_quantity: 0,
        is_preorder: true,
        preorder_release_date: Date.new(2027, 3, 15),
        preorder_quota: 50,
        preorder_reserved: 12,
        preorder_closes_at: nil,
        state: :open_plenty
      }
    ]
  },
  {
    name: "Pokemon: Temporal Forces Elite Trainer Box",
    description: "Elite Trainer Box ชุด Temporal Forces\nบรรจุ 9 Booster Packs + อุปกรณ์เสริม",
    category: pokemon_cat,
    variants: [
      {
        condition: :new_condition,
        language: :en,
        price: 1650,
        stock_quantity: 0,
        is_preorder: true,
        preorder_release_date: Date.new(2027, 2, 28),
        preorder_quota: 20,
        preorder_reserved: 16,
        preorder_closes_at: nil,
        state: :nearly_full
      }
    ]
  },
  {
    name: "One Piece: OP-08 Two Legends Booster Box",
    description: "บูสเตอร์บ็อกซ์ชุด Two Legends (OP-08) 24 แพ็ค\nวางจำหน่าย กุมภาพันธ์ 2027",
    category: one_piece_cat,
    variants: [
      {
        condition: :new_condition,
        language: :ja,
        price: 2800,
        stock_quantity: 0,
        is_preorder: true,
        preorder_release_date: Date.new(2027, 2, 15),
        preorder_quota: 30,
        preorder_reserved: 30,
        preorder_closes_at: nil,
        state: :sold_out
      }
    ]
  },
  {
    name: "Lorcana: Azurite Sea Booster Box (EN) - ปิดรับแล้ว",
    description: "บูสเตอร์บ็อกซ์ชุด Azurite Sea ภาษาอังกฤษ\n⚠️ ปิดรับพรีออเดอร์แล้ว",
    category: lorcana_cat,
    variants: [
      {
        condition: :new_condition,
        language: :en,
        price: 3200,
        stock_quantity: 0,
        is_preorder: true,
        preorder_release_date: Date.new(2027, 1, 20),
        preorder_quota: 40,
        preorder_reserved: 15,
        preorder_closes_at: 3.days.ago,
        state: :closed
      }
    ]
  },
  {
    name: "Pokemon: Scarlet & Violet 151 Booster Box - วางจำหน่ายแล้ว",
    description: "บูสเตอร์บ็อกซ์ชุด 151 ภาษาอังกฤษ\n✅ วางจำหน่ายแล้ว มีสต็อกพร้อมส่ง",
    category: pokemon_cat,
    variants: [
      {
        condition: :new_condition,
        language: :en,
        price: 4200,
        stock_quantity: 15,
        is_preorder: false,
        preorder_release_date: nil,
        preorder_quota: 0,
        preorder_reserved: 0,
        preorder_closes_at: nil,
        state: :released
      }
    ]
  }
]

created_variants = {}
preorder_products.each do |product_data|
  product = product_data[:category].products.find_or_create_by!(name: product_data[:name]) do |p|
    p.description = product_data[:description]
  end

  product_data[:variants].each do |variant_attrs|
    state = variant_attrs.delete(:state)
    variant = product.product_variants.find_or_create_by!(
      condition: variant_attrs[:condition],
      language: variant_attrs[:language]
    ) do |v|
      variant_attrs.each { |k, val| v.send("#{k}=", val) }
    end
    
    # Update existing variants to match seed data
    unless variant.new_record?
      variant.update!(variant_attrs)
    end
    
    created_variants[state] = variant
  end
end

# Create sample pre-order orders in different states
puts "  Creating sample pre-order orders..."

# Order 1: Pending payment with pending_fulfillment item
user1 = customer_users[0]
user1.cart_items.destroy_all
variant1 = created_variants[:open_plenty]

order1 = user1.orders.create!(
  status: :pending_payment,
  subtotal_amount: variant1.price * 2,
  shipping_fee: 50,
  total_amount: variant1.price * 2 + 50,
  postal_code: "10110",
  shipping_zone: "standard",
  payment_deadline_at: 5.minutes.from_now,
  recipient_name: user1.name,
  phone: "081-234-5678",
  address: "123 ถนนทดสอบ แขวงทดสอบ เขททดสอบ กรุงเทพฯ"
)

order1.order_items.create!(
  product_variant: variant1,
  quantity: 2,
  unit_price: variant1.price,
  is_preorder: true,
  preorder_status: :pending_fulfillment
)

variant1.increment!(:preorder_reserved, 2)
order1.create_payment!(method: :bank_transfer, status: :pending)
puts "  ✓ Order ##{order1.id} - รอชำระเงิน (#{user1.name})"

# Order 2: Paid order with pending_fulfillment
user2 = customer_users[1]
user2.cart_items.destroy_all
variant2 = created_variants[:nearly_full]

order2 = user2.orders.create!(
  status: :paid,
  subtotal_amount: variant2.price * 2,
  shipping_fee: 50,
  total_amount: variant2.price * 2 + 50,
  postal_code: "10110",
  shipping_zone: "standard",
  payment_deadline_at: 5.minutes.ago,
  recipient_name: user2.name,
  phone: "081-234-5679",
  address: "456 ถนนทดสอบ แขวงทดสอบ เขททดสอบ กรุงเทพฯ"
)

order2.order_items.create!(
  product_variant: variant2,
  quantity: 2,
  unit_price: variant2.price,
  is_preorder: true,
  preorder_status: :pending_fulfillment
)

variant2.increment!(:preorder_reserved, 2)
order2.create_payment!(method: :bank_transfer, status: :approved, admin_note: "อนุมัติโดย seed script")
puts "  ✓ Order ##{order2.id} - ชำระแล้ว รอสินค้าวางจำหน่าย (#{user2.name})"

# Order 3: Another paid order with pending_fulfillment
user3 = customer_users[2]
user3.cart_items.destroy_all
variant3 = created_variants[:open_plenty]

order3 = user3.orders.create!(
  status: :paid,
  subtotal_amount: variant3.price,
  shipping_fee: 50,
  total_amount: variant3.price + 50,
  postal_code: "10110",
  shipping_zone: "standard",
  payment_deadline_at: 5.minutes.ago,
  recipient_name: user3.name,
  phone: "081-234-5680",
  address: "789 ถนนทดสอบ แขวงทดสอบ เขททดสอบ กรุงเทพฯ"
)

order3.order_items.create!(
  product_variant: variant3,
  quantity: 1,
  unit_price: variant3.price,
  is_preorder: true,
  preorder_status: :pending_fulfillment
)

variant3.increment!(:preorder_reserved, 1)
order3.create_payment!(method: :bank_transfer, status: :approved, admin_note: "อนุมัติโดย seed script")
puts "  ✓ Order ##{order3.id} - ชำระแล้ว รอสินค้าวางจำหน่าย (#{user3.name})"

# Order 4: Paid order with fulfilled item (released product)
variant4 = created_variants[:released]

order4 = user1.orders.create!(
  status: :paid,
  subtotal_amount: variant4.price,
  shipping_fee: 50,
  total_amount: variant4.price + 50,
  postal_code: "10110",
  shipping_zone: "standard",
  payment_deadline_at: 5.minutes.ago,
  recipient_name: user1.name,
  phone: "081-234-5678",
  address: "123 ถนนทดสอบ แขวงทดสอบ เขททดสอบ กรุงเทพฯ"
)

order4.order_items.create!(
  product_variant: variant4,
  quantity: 1,
  unit_price: variant4.price,
  is_preorder: false,  # This was a pre-order but it's released now
  preorder_status: :fulfilled
)

variant4.decrement!(:stock_quantity, 1)
order4.create_payment!(method: :bank_transfer, status: :approved, admin_note: "อนุมัติโดย seed script")
puts "  ✓ Order ##{order4.id} - สินค้าวางจำหน่ายแล้ว ได้รับครบ (#{user1.name})"

# Order 5: Paid order but needs refund (allocation cut)
variant5 = created_variants[:closed]

order5 = user2.orders.create!(
  status: :paid,
  subtotal_amount: variant5.price * 5,
  shipping_fee: 50,
  total_amount: variant5.price * 5 + 50,
  postal_code: "10110",
  shipping_zone: "standard",
  payment_deadline_at: 5.minutes.ago,
  recipient_name: user2.name,
  phone: "081-234-5679",
  address: "456 ถนนทดสอบ แขวงทดสอบ เขททดสอบ กรุงเทพฯ"
)

order5.order_items.create!(
  product_variant: variant5,
  quantity: 5,
  unit_price: variant5.price,
  is_preorder: true,
  preorder_status: :refund_needed
)

variant5.increment!(:preorder_reserved, 5)
order5.create_payment!(method: :bank_transfer, status: :approved, admin_note: "อนุมัติโดย seed script")
puts "  ✓ Order ##{order5.id} - ต้องคืนเงิน (ร้านได้สินค้าไม่ครบ) (#{user2.name})"

puts ""
puts "✅ Pre-order seed data complete!"
puts ""
puts "=" * 70
puts "🔐 LOGIN CREDENTIALS"
puts "=" * 70
puts ""
puts "👤 Admin:"
puts "   Email:    admin@carshop.local"
puts "   Password: password123"
puts ""
puts "👥 Customers:"
customers.each_with_index do |customer, i|
  puts "   Customer #{i + 1} (#{customer[:name]}):"
  puts "   Email:    #{customer[:email]}"
  puts "   Password: #{customer[:password]}"
  puts ""
end
puts "=" * 70
puts ""
puts "📦 Pre-order Variants Created:"
puts "   ✅ Open with plenty quota: #{created_variants[:open_plenty].product.name}"
puts "      Quota: #{created_variants[:open_plenty].preorder_quota}, Reserved: #{created_variants[:open_plenty].preorder_reserved}"
puts ""
puts "   ⚠️  Nearly full: #{created_variants[:nearly_full].product.name}"
puts "      Quota: #{created_variants[:nearly_full].preorder_quota}, Reserved: #{created_variants[:nearly_full].preorder_reserved}"
puts ""
puts "   ❌ Sold out: #{created_variants[:sold_out].product.name}"
puts "      Quota: #{created_variants[:sold_out].preorder_quota}, Reserved: #{created_variants[:sold_out].preorder_reserved}"
puts ""
puts "   🔒 Closed: #{created_variants[:closed].product.name}"
puts "      Closed at: #{created_variants[:closed].preorder_closes_at}"
puts ""
puts "   📍 Released: #{created_variants[:released].product.name}"
puts "      Stock: #{created_variants[:released].stock_quantity} units"
puts ""
puts "=" * 70
puts ""
puts "🎯 WALKTHROUGH STEPS:"
puts ""
puts "1. Login as customer (customer1@test.local / customer123)"
puts "2. Browse products - see pre-order badges, release dates, quotas"
puts "3. Try adding 'Open with plenty' variant to cart"
puts "4. Go to checkout - see the orange warning about allocation cuts"
puts "5. Check the acknowledgment checkbox and complete order"
puts ""
puts "6. Login as admin (admin@carshop.local / password123)"
puts "7. Go to Admin → Products → Edit any pre-order product"
puts "8. See pre-order configuration fields (release date, quota, etc.)"
puts "9. Go to Admin → Orders"
puts "10. View order details - see pre-order items with badges and statuses"
puts "11. For paid pre-order items, click '❌ ต้องคืนเงิน' to mark as needing refund"
puts ""
puts "=" * 70
