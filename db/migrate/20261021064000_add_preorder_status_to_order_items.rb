class AddPreorderStatusToOrderItems < ActiveRecord::Migration[8.1]
  def change
    add_column :order_items, :is_preorder, :boolean, default: false, null: false
    add_column :order_items, :preorder_status, :integer, default: 0, null: false
  end
end
