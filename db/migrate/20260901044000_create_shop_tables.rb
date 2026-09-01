# frozen_string_literal: true

class CreateShopTables < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    create_table :products do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :condition, null: false, default: 0
      t.integer :language, null: false, default: 0
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :stock_quantity, null: false, default: 0

      t.timestamps
    end

    add_index :product_variants, %i[product_id condition language], unique: true, name: "index_variants_on_product_condition_language"

    create_table :cart_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end

    add_index :cart_items, %i[user_id product_variant_id], unique: true

    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.decimal :total_amount, precision: 10, scale: 2, null: false, default: 0
      t.string :recipient_name, null: false
      t.string :phone, null: false
      t.text :address, null: false
      t.string :tracking_number
      t.datetime :shipped_at

      t.timestamps
    end

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false

      t.timestamps
    end

    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true, index: { unique: true }
      t.integer :method, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.text :admin_note

      t.timestamps
    end

    create_table :shop_settings do |t|
      t.string :bank_name
      t.string :account_number
      t.string :account_name
      t.text :payment_instructions

      t.timestamps
    end
  end
end
