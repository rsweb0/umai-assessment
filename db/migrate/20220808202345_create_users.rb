# frozen_string_literal: true

# CreateUsers
class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email, index: { unique: true }
      t.string :encrypted_password, null: false
      t.timestamps
    end
  end
end
