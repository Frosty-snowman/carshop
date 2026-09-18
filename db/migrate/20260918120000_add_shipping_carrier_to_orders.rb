class AddShippingCarrierToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :shipping_carrier, :integer
  end
end
