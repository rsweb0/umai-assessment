# frozen_string_literal: true

require_relative 'application_record'

# rating model
class Rating < ApplicationRecord
  validates_inclusion_of :value, in: 1..5

  belongs_to :post
end
