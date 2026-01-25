# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Sign In', type: :feature do
  let(:user) { create(:user) }
  let(:valid_id_number) { user.id_number }
  let(:valid_password) { 'password123' }

  before do
    visit new_user_session_path
  end

  describe 'sign in page' do
    context 'when id_number and password are both correct' do
      it 'signs in successfully, redirects to /admin/dashboard, and displays success message' do
        fill_in 'user_id_number', with: valid_id_number
        fill_in 'user_password', with: valid_password
        click_button '登入'

        expect(page).to have_current_path(admin_root_path)
        expect(page).to have_content('成功登入')
      end
    end

    context 'when id_number is incorrect' do
      it 'fails to sign in, stays on the same page, and displays error message' do
        fill_in 'user_id_number', with: 'A123456789'
        fill_in 'user_password', with: valid_password
        click_button '登入'

        expect(page).to have_current_path(user_session_path)
        expect(page).to have_content('無效的身分證字號或密碼')
      end
    end

    context 'when password is incorrect' do
      it 'fails to sign in, stays on the same page, and displays error message' do
        fill_in 'user_id_number', with: valid_id_number
        fill_in 'user_password', with: 'wrong_password'
        click_button '登入'

        expect(page).to have_current_path(user_session_path)
        expect(page).to have_content('無效的身分證字號或密碼')
      end
    end

    context 'when both id_number and password are incorrect' do
      it 'fails to sign in, stays on the same page, and displays error message' do
        fill_in 'user_id_number', with: 'A123456789'
        fill_in 'user_password', with: 'wrong_password'
        click_button '登入'

        expect(page).to have_current_path(user_session_path)
        expect(page).to have_content('無效的身分證字號或密碼')
      end
    end
  end
end
