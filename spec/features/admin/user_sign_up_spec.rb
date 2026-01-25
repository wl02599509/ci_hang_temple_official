# frozen_string_literal: true

require 'rails_helper'
require 'taiwanese_id_validator/twid_generator'

RSpec.describe 'User Sign Up', type: :feature do
  let(:valid_id_number) { TwidGenerator.generate }
  let(:valid_attributes) do
    {
      id_number: valid_id_number,
      name: 'Test User',
      phone_number: '0912345678',
      birth_date: '1990-01-01',
      address: 'Test Address',
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    }
  end

  before do
    visit new_user_registration_path
  end

  describe 'sign up page' do
    context 'when signs up successfully' do
      before do
        fill_in_registration_form
        click_button '註冊'
      end

      it { expect(User.count).to eq(1) }
      it { expect(page).to have_current_path(admin_root_path) }
      it { expect(page).to have_content('歡迎') }
    end

    context 'when id_number is blank' do
      before do
        fill_in_registration_form(valid_attributes.merge(id_number: ''))
        click_button '註冊'
      end

      it { expect(User.count).to eq(0) }
      it { expect(page).to have_current_path(user_registration_path) }
      it { expect(page).to have_content('不能為空白') }
    end

    context 'when id_number is invalid format' do
      before do
        fill_in_registration_form(valid_attributes.merge(id_number: 'INVALID123'))
        click_button '註冊'
      end

      it { expect(User.count).to eq(0) }
      it { expect(page).to have_current_path(user_registration_path) }
      it { expect(page).to have_content('格式不正確') }
    end

    context 'when id_number is already taken' do
      before do
        create(:user, id_number: valid_attributes[:id_number])
        fill_in_registration_form
        click_button '註冊'
      end

      it { expect(User.count).to eq(1) }
      it { expect(page).to have_current_path(user_registration_path) }
      it { expect(page).to have_content('已經被使用') }
    end

    context 'when name is blank' do
      before do
        fill_in_registration_form(valid_attributes.merge(name: ''))
        click_button '註冊'
      end

      it { expect(User.count).to eq(0) }
      it { expect(page).to have_current_path(user_registration_path) }
      it { expect(page).to have_content('不能為空白') }
    end

    context 'when birth_date is blank' do
      before do
        fill_in_registration_form(valid_attributes.merge(birth_date: ''))
        click_button '註冊'
      end

      it { expect(User.count).to eq(0) }
      it { expect(page).to have_current_path(user_registration_path) }
      it { expect(page).to have_content('不能為空白') }
    end

    context 'when address is blank' do
      before do
        fill_in_registration_form(valid_attributes.merge(address: ''))
        click_button '註冊'
      end

      it { expect(User.count).to eq(0) }
      it { expect(page).to have_current_path(user_registration_path) }
      it { expect(page).to have_content('不能為空白') }
    end

    context 'when email format is invalid' do
      before do
        fill_in_registration_form(valid_attributes.merge(email: 'invalid-email'))
        click_button '註冊'
      end

      it { expect(User.count).to eq(0) }
      it { expect(page).to have_current_path(user_registration_path) }
      it { expect(page).to have_content('格式不正確') }
    end

    context 'when password is blank' do
      before do
        fill_in_registration_form(valid_attributes.merge(password: '', password_confirmation: ''))
        click_button '註冊'
      end

      it { expect(User.count).to eq(0) }
      it { expect(page).to have_current_path(user_registration_path) }
      it { expect(page).to have_content('不能為空白') }
    end

    context 'when password is too short' do
      before do
        fill_in_registration_form(valid_attributes.merge(password: '12345', password_confirmation: '12345'))
        click_button '註冊'
      end

      it { expect(User.count).to eq(0) }
      it { expect(page).to have_current_path(user_registration_path) }
      it { expect(page).to have_content('太短') }
    end

    context 'when password_confirmation does not match' do
      before do
        fill_in_registration_form(valid_attributes.merge(password_confirmation: 'different_password'))
        click_button '註冊'
      end

      it { expect(User.count).to eq(0) }
      it { expect(page).to have_current_path(user_registration_path) }
      it { expect(page).to have_content('與密碼不符') }
    end
  end

  def fill_in_registration_form(attributes = valid_attributes)
    fill_in 'user_id_number', with: attributes[:id_number]
    fill_in 'user_name', with: attributes[:name]
    fill_in 'user_phone_number', with: attributes[:phone_number]
    fill_in 'user_birth_date', with: attributes[:birth_date]
    fill_in 'user_address', with: attributes[:address]
    fill_in 'user_email', with: attributes[:email] if attributes.key?(:email)
    fill_in 'user_password', with: attributes[:password]
    fill_in 'user_password_confirmation', with: attributes[:password_confirmation]
  end
end
