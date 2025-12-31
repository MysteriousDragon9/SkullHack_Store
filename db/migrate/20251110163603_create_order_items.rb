class CreateOrderItems < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string  :status, null: false, default: "pending" # pending, paid, canceled, shipped
      t.decimal :subtotal, precision: 10, scale: 2, null: false, default: 0
      t.decimal :tax_total, precision: 10, scale: 2, null: false, default: 0
      t.decimal :grand_total, precision: 10, scale: 2, null: false, default: 0
      t.string  :shipping_address
      t.string  :shipping_province_name
      t.decimal :shipping_tax_rate, precision: 5, scale: 2, default: 0
      t.timestamps
    end

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :line_total, precision: 10, scale: 2, null: false
      t.timestamps
    end
  end
end
