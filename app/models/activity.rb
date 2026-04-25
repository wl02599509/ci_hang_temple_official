class Activity < ApplicationRecord
  has_many_attached :photos
  has_many :activity_registrations, dependent: :destroy
  has_many :registered_users, through: :activity_registrations, source: :user

  enum :status, { draft: 0, published: 1 }

  validates :title, presence: true
  validates :description, presence: true
  validates :event_date, presence: true
  validates :registration_start_date, presence: true
  validates :registration_end_date, presence: true
  validates :fee, presence: true
  validate :registration_end_date_on_or_after_start_date

  def self.ransackable_attributes(auth_object = nil)
    %w[title event_date status]
  end

  private

  def registration_end_date_on_or_after_start_date
    return unless registration_start_date && registration_end_date
    if registration_end_date < registration_start_date
      errors.add(:registration_end_date, :invalid)
    end
  end
end
