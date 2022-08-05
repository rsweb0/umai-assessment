# frozen_string_literal: true

require 'bcrypt'
require_relative 'application_record'

# user model
class User < ApplicationRecord
  include BCrypt

  validates :encrypted_password, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  has_many :feedbacks, foreign_key: :owner_id, dependent: :destroy

  def self.authenticate(email, password)
    user = find_by_email(email)
    return { success: false, error_code: :user_not_found } unless user

    return { success: false, error_code: :invalid_password } unless user.valid_password?(password)

    { success: true, user: user }
  end

  def valid_password?(entered_password)
    password == entered_password
  end

  def password
    @password ||= Password.new(encrypted_password)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.encrypted_password = @password
  end
end
