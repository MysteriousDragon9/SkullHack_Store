class AddDefaultStatusToOrders < ActiveRecord::Migration[7.0]
  def change
    change_column_default :orders, :status, from: nil, to: 0
    change_column_null :orders, :status, false
  end
end
