class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :sex, { male: 1, female: 2 }, validate: true
  enum :zodiac, {
    mice: 1,      # 鼠
    ox: 2,       # 牛
    tiger: 3,    # 虎
    rabbit: 4,   # 兔
    dragon: 5,   # 龍
    snake: 6,    # 蛇
    horse: 7,    # 馬
    goat: 8,     # 羊
    monkey: 9,   # 猴
    rooster: 10, # 雞
    dog: 11,     # 狗
    pig: 12      # 豬
  }, validate: { allow_nil: true }
  enum :status, {
    master: 0,     # 宮主
    vice_master: 1, # 主持
    president: 2, # 理事長
    executive_director: 3, # 常務理事
    executive_supervisor: 4, # 常務監事
    director: 5, # 理事
    supervisor: 6, # 監事
    consultant: 7, # 顧問
    member: 8, # 會員
    volunteer: 98, # 志工
    normal: 99 # 善信大德
  }, validate: true


  validates :id_number, presence: true,
                        uniqueness: { case_sensitive: false },
                        taiwanese_id: { case_sensitive: false, message: :invalid }
  validates :name, presence: true
  validates :birth_date, presence: true
  validates :address, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  before_validation :set_sex

  class << self
    def ransackable_attributes(auth_object = nil)
      %w[id_number name sex birth_date status address email zodiac phone_number]
    end

    def ransackable_associations(auth_object = nil)
      []
    end
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def id_number=(value)
    super(value&.upcase)
  end

  def set_sex
    return if id_number.blank?

    gender_digit = id_number[1].to_i
    self.sex =
      case gender_digit
      when 1
        :male
      when 2
        :female
      end
  end
end
