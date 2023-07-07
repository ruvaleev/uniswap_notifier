# frozen_string_literal: true

class User < ActiveRecord::Base
  include BCrypt

  has_many :authentications, dependent: :destroy
  has_many :notification_statuses, dependent: :destroy
  has_many :positions, dependent: :destroy

  validates :address, :login, presence: true, uniqueness: true
  validates :password_hash, presence: true
  validate :password_length

  MAX_PASSWORD_LENGTH = 20
  MIN_PASSWORD_LENGTH = 8

  attr_reader :password

  def password=(value)
    @password = value.to_s
    self.password_hash = Password.create(value)
  end

  private

  def password_length
    return unless password
    return if password.length >= MIN_PASSWORD_LENGTH && password.length <= MAX_PASSWORD_LENGTH

    errors.add(:password, :invalid)
  end
end
