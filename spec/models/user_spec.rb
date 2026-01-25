require 'rails_helper'

RSpec.describe User, type: :model do
  # ========== Devise Modules ==========
  describe 'devise modules' do
    it 'includes database_authenticatable module' do
      expect(described_class.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable module' do
      expect(described_class.devise_modules).to include(:registerable)
    end

    it 'includes recoverable module' do
      expect(described_class.devise_modules).to include(:recoverable)
    end

    it 'includes rememberable module' do
      expect(described_class.devise_modules).to include(:rememberable)
    end

    it 'includes validatable module' do
      expect(described_class.devise_modules).to include(:validatable)
    end
  end

  # ========== Enums - 使用 Shoulda Matchers ==========
  describe 'enums' do
    it do
      expect(subject).to define_enum_for(:sex)
        .with_values(male: 1, female: 2)
        .backed_by_column_of_type(:integer)
    end

    it do
      expect(subject).to define_enum_for(:zodiac)
        .with_values(
          mice: 1,
          ox: 2,
          tiger: 3,
          rabbit: 4,
          dragon: 5,
          snake: 6,
          horse: 7,
          goat: 8,
          monkey: 9,
          rooster: 10,
          dog: 11,
          pig: 12
        )
        .backed_by_column_of_type(:integer)
    end

    it do
      expect(subject).to define_enum_for(:status)
        .with_values(
          master: 0,
          vice_master: 1,
          president: 2,
          executive_director: 3,
          executive_supervisor: 4,
          director: 5,
          supervisor: 6,
          consultant: 7,
          member: 8,
          volunteer: 98,
          normal: 99
        )
        .backed_by_column_of_type(:integer)
    end
  end

  # ========== Validations - 使用 Shoulda Matchers ==========
  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:id_number) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:birth_date) }
    it { is_expected.to validate_presence_of(:address) }

    describe 'id_number uniqueness' do
      subject { create(:user) }

      it { is_expected.to validate_uniqueness_of(:id_number).case_insensitive }
    end

    describe 'email format validation' do
      it { is_expected.to allow_value('').for(:email) }
      it { is_expected.to allow_value(nil).for(:email) }
      it { is_expected.to allow_value('test@example.com').for(:email) }
      it { is_expected.not_to allow_value('invalid_email').for(:email) }
      it { is_expected.not_to allow_value('test@').for(:email) }
      it { is_expected.not_to allow_value('@example.com').for(:email) }
    end
  end

  # ========== Callbacks ==========
  describe 'callbacks' do
    describe 'before_validation :set_sex' do
      context 'when id_number has gender digit 1 (at index 1)' do
        it 'sets sex to male' do
          user = build(:user, id_number: 'A123456789')
          user.valid?
          expect(user.sex).to eq('male')
        end
      end

      context 'when id_number has gender digit 2 (at index 1)' do
        it 'sets sex to female' do
          user = build(:user, id_number: 'B223456789')
          user.valid?
          expect(user.sex).to eq('female')
        end
      end
    end
  end

  # ========== Custom Methods ==========
  describe '#email_required?' do
    it 'returns false' do
      user = build(:user)
      expect(user.email_required?).to be false
    end
  end

  describe '#email_changed?' do
    it 'returns false' do
      user = build(:user)
      expect(user.email_changed?).to be false
    end
  end

  describe '#id_number=' do
    it 'converts id_number to uppercase' do
      user = build(:user)
      user.id_number = 'a123456789'
      expect(user.id_number).to eq('A123456789')
    end

    it 'handles nil value' do
      user = build(:user)
      user.id_number = nil
      expect(user.id_number).to be_nil
    end

    it 'preserves already uppercase id_number' do
      user = build(:user)
      user.id_number = 'B223456789'
      expect(user.id_number).to eq('B223456789')
    end
  end

  describe '#set_sex' do
    it 'extracts sex from id_number second character (index 1)' do
      user = build(:user, id_number: 'A123456789')
      user.send(:set_sex)
      expect(user.sex).to eq('male')
    end

    it 'sets sex to female when second character is 2' do
      user = build(:user, id_number: 'B223456789')
      user.send(:set_sex)
      expect(user.sex).to eq('female')
    end

    it 'handles nil id_number gracefully' do
      user = build(:user)
      user.id_number = nil
      expect { user.send(:set_sex) }.not_to raise_error
    end
  end

  # ========== Factory Tests ==========
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end

    it 'has a valid female factory' do
      expect(build(:user, :female)).to be_valid
    end

    it 'has a valid factory without email' do
      expect(build(:user, :without_email)).to be_valid
    end

    it 'has a valid factory with zodiac' do
      expect(build(:user, :with_zodiac)).to be_valid
    end

    it 'creates user with different statuses' do
      expect(create(:user, :master).status).to eq('master')
      expect(create(:user, :member).status).to eq('member')
      expect(create(:user, :volunteer).status).to eq('volunteer')
    end
  end

  # ========== Database Constraints ==========
  describe 'database constraints' do
    it 'requires id_number to be unique' do
      user1 = create(:user, id_number: 'A123456789')
      user2 = build(:user, id_number: 'A123456789')

      expect(user2).not_to be_valid
      expect(user2.errors[:id_number]).to include('已經被使用')
    end

    it 'is case insensitive for id_number uniqueness' do
      create(:user, id_number: 'A123456789')
      user2 = build(:user, id_number: 'a123456789')

      expect(user2).not_to be_valid
    end
  end

  # ========== Default Values ==========
  describe 'default values' do
    it 'sets default status to normal' do
      user = described_class.new(
        id_number: 'C199999999',
        name: 'Test User',
        birth_date: Date.today - 30.years,
        address: 'Test Address',
        phone_number: '0912345678',
        password: 'password123'
      )
      user.save
      expect(user.status).to eq('normal')
    end
  end

  # ========== Edge Cases ==========
  describe 'edge cases' do
    it 'allows user without email' do
      user = build(:user, email: nil)
      expect(user).to be_valid
    end

    it 'allows user without zodiac' do
      user = build(:user, zodiac: nil)
      expect(user).to be_valid
    end

    it 'rejects user without required fields' do
      user = described_class.new
      expect(user).not_to be_valid
      expect(user.errors).to include(:id_number, :name, :birth_date, :address)
    end
  end
end
