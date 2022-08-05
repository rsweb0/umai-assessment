# frozen_string_literal: true

# CreatePosts
class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.references :user, null: false
      t.string :title, null: false
      t.text :content, null: false
      t.string :author_ip, null: false
      t.timestamps
    end
  end
end
