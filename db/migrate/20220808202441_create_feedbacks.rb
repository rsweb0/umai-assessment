# frozen_string_literal: true

# CreateFeedbacks
class CreateFeedbacks < ActiveRecord::Migration[5.2]
  def change
    create_table :feedbacks do |t|
      t.references :feedable, polymorphic: true
      t.references :owner, foreign_key: { to_table: :users }
      t.text :comment
      t.timestamps
    end

    add_index :feedbacks, %i[feedable_type feedable_id owner_id], unique: true,
                                                                  name: 'unique_index_on_feedable_and_owner'
  end
end
