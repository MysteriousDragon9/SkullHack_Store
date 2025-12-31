class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true
      t.string :status, null: false, default: "new"
      t.string :payment_id
      t.string :shipping_address
      t.references :province, foreign_key: true
      t.decimal :subtotal, precision: 10, scale: 2, null: false, default: 0
      t.decimal :gst_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :pst_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :hst_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :total, precision: 10, scale: 2, null: false, default: 0
      t.timestamps
    end
  end
end
