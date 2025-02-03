module Admin
  class Member < ApplicationRecord
    self.table_name = 'admin_members'

    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable

    validates :id_card_number, presence: true,
                               uniqueness: { case_sensitive: false },
                               format: { with: /\A[A-Z][1-2]\d{8}\z/ }
    validates :home_phone_number, length: { is: 10 }, allow_blank: true
    validates :mobile_phone_number, length: { is: 10 }, allow_blank: true
    validates :name, presence: true

    def email_required?
      false
    end

    def email_changed?
      false
    end

    def partial_id_card_number
      partial_range = 3..7
      id_card_number.split('').each_with_index.map do |char, index|
        index.in?(partial_range) ? '*' : char
      end.join
    end
  end
end
