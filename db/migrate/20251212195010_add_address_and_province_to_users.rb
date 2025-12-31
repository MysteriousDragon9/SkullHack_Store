class AddAddressAndProvinceToUsers < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :province, foreign_key: true # no null: false
  end
end
