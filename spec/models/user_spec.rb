# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject(:user) { build(:user) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:id_card_number) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_uniqueness_of(:id_card_number).case_insensitive }
    it { is_expected.to validate_length_of(:home_phone_number).is_equal_to(10) }
    it { is_expected.to validate_length_of(:mobile_phone_number).is_equal_to(10) }

    it do
      expect(user).to define_enum_for(:status).with_values(User::STATUSES)
                                              .with_default(:general)
                                              .with_suffix(:status)
                                              .backed_by_column_of_type(:string)
    end
  end

  describe 'devise settings' do
    it 'does not require email' do
      user = build(:user, email: nil)
      expect(user.email_required?).to be false
    end

    it 'does not track email changes' do
      user = build(:user)
      expect(user.email_changed?).to be false
    end
  end
end
