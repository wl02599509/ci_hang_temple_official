# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Member, type: :model do
  describe 'validations' do
    subject(:admin_member) { build(:admin_member) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:id_card_number) }
    it { is_expected.to validate_presence_of(:permission) }
    it { is_expected.to validate_uniqueness_of(:id_card_number).case_insensitive }
    it { is_expected.to validate_length_of(:home_phone_number).is_equal_to(10) }
    it { is_expected.to validate_length_of(:mobile_phone_number).is_equal_to(10) }

    it do
      expect(admin_member).to define_enum_for(:permission).with_values(member: 'member', admin: 'admin')
                                                          .with_default(:member)
                                                          .with_suffix(:permission)
                                                          .backed_by_column_of_type(:string)
    end
  end

  describe 'devise settings' do
    it 'does not require email' do
      member = build(:admin_member, email: nil)
      expect(member.email_required?).to be false
    end

    it 'does not track email changes' do
      member = build(:admin_member)
      expect(member.email_changed?).to be false
    end
  end
end
