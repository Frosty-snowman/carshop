class AddReservationsShippingAndFeatureRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :product_variants, :reserved_quantity, :integer, default: 0, null: false

    add_column :orders, :subtotal_amount, :decimal, precision: 10, scale: 2, default: "0.0", null: false
    add_column :orders, :shipping_fee, :decimal, precision: 10, scale: 2, default: "0.0", null: false
    add_column :orders, :postal_code, :string
    add_column :orders, :shipping_zone, :string, default: "standard", null: false
    add_column :orders, :payment_deadline_at, :datetime

    reversible do |dir|
      dir.up do
        execute "UPDATE orders SET subtotal_amount = total_amount WHERE subtotal_amount = 0"
      end
    end

    create_table :feature_requests do |t|
      t.references :user, foreign_key: true, null: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :title, null: false
      t.text :description, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
