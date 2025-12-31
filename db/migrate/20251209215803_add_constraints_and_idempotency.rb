class AddConstraintsAndIdempotency < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      UPDATE products SET price = 0.0 WHERE price IS NULL;
      UPDATE products SET stock_quantity = 0 WHERE stock_quantity IS NULL;
      UPDATE order_items SET unit_price = 0.0 WHERE unit_price IS NULL;
      UPDATE order_items SET quantity = 1 WHERE quantity IS NULL;
      UPDATE orders SET total_price = 0.0 WHERE total_price IS NULL;
    SQL

    change_column :products, :price, :decimal, precision: 10, scale: 2, null: false, default: "0.0"
    change_column_null :products, :stock_quantity, false, 0
    change_column_default :products, :stock_quantity, from: nil, to: 0
    add_check_constraint :products, "price >= 0", name: "products_price_non_negative"
    add_check_constraint :products, "stock_quantity >= 0", name: "products_stock_non_negative"

    change_column :order_items, :unit_price, :decimal, precision: 10, scale: 2, null: false, default: "0.0"
    change_column_null :order_items, :quantity, false, 1
    add_check_constraint :order_items, "quantity > 0", name: "order_items_quantity_positive"

    change_column :orders, :total_price, :decimal, precision: 12, scale: 2, null: false, default: "0.0"
    add_column :orders, :idempotency_key, :string unless column_exists?(:orders, :idempotency_key)
    add_index :orders, :idempotency_key, unique: true, name: "index_orders_on_idempotency_key"
  end

  def down
    remove_index :orders, name: "index_orders_on_idempotency_key" if index_exists?(:orders, :idempotency_key)
    remove_column :orders, :idempotency_key if column_exists?(:orders, :idempotency_key)

    change_column :orders, :total_price, :decimal, precision: nil, scale: nil, null: true, default: nil
    change_column_null :order_items, :quantity, true
    change_column :order_items, :unit_price, :decimal, precision: nil, scale: nil, null: true, default: nil
    change_column_null :products, :stock_quantity, true
    change_column :products, :price, :decimal, precision: nil, scale: nil, null: true, default: nil

    remove_check_constraint :order_items, name: "order_items_quantity_positive" if constraint_exists?(:order_items, "order_items_quantity_positive")
    remove_check_constraint :products, name: "products_stock_non_negative" if constraint_exists?(:products, "products_stock_non_negative")
    remove_check_constraint :products, name: "products_price_non_negative" if constraint_exists?(:products, "products_price_non_negative")
  end

  private

  def constraint_exists?(table, name)
    constraints = select_all(<<~SQL)
      SELECT conname FROM pg_constraint WHERE conname = #{ActiveRecord::Base.connection.quote(name)}
    SQL
    constraints.any?
  end
end
