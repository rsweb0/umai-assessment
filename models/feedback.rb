# frozen_string_literal: true

require_relative 'application_record'

# Feedback model
class Feedback < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  belongs_to :feedable, polymorphic: true

  validates :comment, presence: true
  validates_uniqueness_of :owner, scope: :feedable,
                                  message: ->(f, _) { "You have already added feedback to this #{f.feedable_type}" }

  delegate :email, to: :owner, prefix: true
end
