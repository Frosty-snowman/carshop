class AddPreorderToProductVariants < ActiveRecord::Migration[8.1]
  def change
    add_column :product_variants, :is_preorder, :boolean, default: false, null: false
    add_column :product_variants, :preorder_release_date, :date
    add_column :product_variants, :preorder_quota, :integer, default: 0, null: false
    add_column :product_variants, :preorder_reserved, :integer, default: 0, null: false
    add_column :product_variants, :preorder_closes_at, :datetime
  end
end
