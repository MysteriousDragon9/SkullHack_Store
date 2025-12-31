class AddIsNewToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :is_new, :boolean, default: false, null: false
    add_column :products, :recently_updated, :boolean, default: false, null: false
    add_index :products, :is_new
    add_index :products, :recently_updated
  end
end
