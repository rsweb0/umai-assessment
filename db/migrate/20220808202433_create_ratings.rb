# frozen_string_literal: true

# CreateRatings
class CreateRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :ratings do |t|
      t.references :post, null: false
      t.integer :value, null: false
      t.timestamps
    end
  end
end
