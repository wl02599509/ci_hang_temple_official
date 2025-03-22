# frozen_string_literal: true

class User < ApplicationRecord
  self.table_name = 'users'

  STATUSES = {
    general: 'general',
    member: 'member',
    supervisor: 'supervisor',
    executive_supervisor: 'executive_supervisor',
    director: 'director',
    executive_director: 'executive_director',
    chairman: 'chairman',
    preside: 'preside',
    temple_president: 'temple_president'
  }.freeze

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :status, STATUSES, default: :general, suffix: true

  validates :id_card_number, presence: true,
                             uniqueness: { case_sensitive: false },
                             format: { with: /\A[a-zA-Z][1-2]\d{8}\z/ }
  validates :home_phone_number, length: { is: 10 }, allow_blank: true
  validates :mobile_phone_number, length: { is: 10 }, allow_blank: true
  validates :name, presence: true
  validates :status, presence: true

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def partial_id_card_number
    partial_range = 3..7
    id_card_number.chars.each_with_index.map do |char, index|
      index.in?(partial_range) ? '*' : char
    end.join
  end
end
