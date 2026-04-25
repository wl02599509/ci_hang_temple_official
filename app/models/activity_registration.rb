class ActivityRegistration < ApplicationRecord
  belongs_to :activity
  belongs_to :user

  enum :status, { pending: 0, paid: 1, cancelled: 2 }
  enum :payment_method, { transfer: 0, cash: 1 }, validate: { allow_nil: true }

  scope :active, -> { where(status: [ :pending, :paid ]) }
  scope :cancellable, -> { where(status: [ :pending, :paid ]) }
end
