class AddUniqueIdempotencyIndexToOrders < ActiveRecord::Migration[7.2]
  def change
    add_index :orders, [ :idempotency_key, :user_id ], unique: true, where: "idempotency_key IS NOT NULL", name: "index_orders_on_idempotency_and_user"
  end
end
