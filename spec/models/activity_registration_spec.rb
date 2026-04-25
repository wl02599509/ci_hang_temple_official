require 'rails_helper'

RSpec.describe ActivityRegistration, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:activity) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, paid: 1, cancelled: 2).backed_by_column_of_type(:integer) }
    it { is_expected.to define_enum_for(:payment_method).with_values(transfer: 0, cash: 1).backed_by_column_of_type(:integer) }
  end

  describe 'scopes' do
    let(:activity) { create(:activity) }
    let!(:pending_reg) { create(:activity_registration, activity: activity, user: create(:user), status: :pending) }
    let!(:paid_reg) { create(:activity_registration, activity: activity, user: create(:user), status: :paid, payment_method: :cash, collector: 'Test', paid_at: Time.current) }
    let!(:cancelled_reg) { create(:activity_registration, activity: activity, user: create(:user), status: :cancelled, cancel_reason: 'reason', cancelled_at: Time.current) }

    describe '.active' do
      it 'includes pending registrations' do
        expect(described_class.active).to include(pending_reg)
      end

      it 'includes paid registrations' do
        expect(described_class.active).to include(paid_reg)
      end

      it 'excludes cancelled registrations' do
        expect(described_class.active).not_to include(cancelled_reg)
      end
    end

    describe '.cancellable' do
      it 'includes pending registrations' do
        expect(described_class.cancellable).to include(pending_reg)
      end

      it 'includes paid registrations' do
        expect(described_class.cancellable).to include(paid_reg)
      end

      it 'excludes cancelled registrations' do
        expect(described_class.cancellable).not_to include(cancelled_reg)
      end
    end
  end
end
