# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[7.2]
  def up
    change_table :users do |t|
      # Database authenticatable
      unless column_exists?(:users, :email)
        t.string :email, null: false, default: ""
      end

      unless column_exists?(:users, :encrypted_password)
        t.string :encrypted_password, null: false, default: ""
      end

      # Recoverable
      unless column_exists?(:users, :reset_password_token)
        t.string :reset_password_token
      end
      unless column_exists?(:users, :reset_password_sent_at)
        t.datetime :reset_password_sent_at
      end

      # Rememberable
      unless column_exists?(:users, :remember_created_at)
        t.datetime :remember_created_at
      end

      # Uncomment/guard other Devise fields if you need them
      # e.g. confirmable, lockable, trackable...
    end

    add_index :users, :email, unique: true unless index_exists?(:users, :email)
    add_index :users, :reset_password_token, unique: true unless index_exists?(:users, :reset_password_token)
  end

  def down
    # If you want to remove columns on rollback, implement carefully.
    raise ActiveRecord::IrreversibleMigration
  end
end
