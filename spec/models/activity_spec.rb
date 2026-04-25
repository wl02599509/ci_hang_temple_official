require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:event_date) }
    it { is_expected.to validate_presence_of(:registration_start_date) }
    it { is_expected.to validate_presence_of(:registration_end_date) }
    it { is_expected.to validate_presence_of(:fee) }

    describe 'registration_end_date >= registration_start_date' do
      it 'is invalid when registration_end_date is before registration_start_date' do
        activity = build(:activity,
          registration_start_date: Date.today + 10,
          registration_end_date: Date.today + 5)
        expect(activity).not_to be_valid
        expect(activity.errors[:registration_end_date]).to be_present
      end

      it 'is valid when registration_end_date equals registration_start_date' do
        activity = build(:activity,
          registration_start_date: Date.today + 5,
          registration_end_date: Date.today + 5)
        expect(activity).to be_valid
      end

      it 'is valid when registration_end_date is after registration_start_date' do
        activity = build(:activity,
          registration_start_date: Date.today + 5,
          registration_end_date: Date.today + 10)
        expect(activity).to be_valid
      end
    end
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(draft: 0, published: 1).backed_by_column_of_type(:integer) }
  end

  describe 'associations' do
    it 'has many attached photos' do
      expect(described_class.new.photos).to be_a(ActiveStorage::Attached::Many)
    end

    it { is_expected.to have_many(:activity_registrations).dependent(:destroy) }
    it { is_expected.to have_many(:registered_users).through(:activity_registrations).source(:user) }
  end

  describe '.ransackable_attributes' do
    it 'includes title' do
      expect(described_class.ransackable_attributes).to include('title')
    end

    it 'includes event_date' do
      expect(described_class.ransackable_attributes).to include('event_date')
    end

    it 'includes status' do
      expect(described_class.ransackable_attributes).to include('status')
    end
  end
end
