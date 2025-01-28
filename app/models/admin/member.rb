
module Admin
  class Member < ApplicationRecord
    self.table_name = 'admin_members'

    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable

    validates :id_card_number, presence: true, uniqueness: true
    validates :home_phone_number, :mobile_phone_number, length: { is: 10 }, allow_blank: true
    validates :name, presence: true

    def email_required?
      false
    end

    def email_changed?
      false
    end
  end
end
