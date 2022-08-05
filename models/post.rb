# frozen_string_literal: true

require_relative 'application_record'

# post model
class Post < ApplicationRecord
  validates :title, :content, :author_ip, presence: true

  has_many :ratings, dependent: :destroy

  belongs_to :user

  def average_rating
    (ratings.sum(:value).to_f / ratings.count).round(2)
  end
end
