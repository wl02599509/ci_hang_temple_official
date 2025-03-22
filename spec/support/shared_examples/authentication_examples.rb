# frozen_string_literal: true

RSpec.shared_examples 'admin signin attempt' do |status, is_successful|
  let(:user) { create(:user, status) }

  before do
    visit new_admin_user_session_path
    fill_in 'admin_user[id_card_number]', with: user.id_card_number
    fill_in 'admin_user[password]', with: user.password
    click_button '登入'
  end

  if is_successful
    it 'allows signin and redirects to dashboard' do
      expect(current_path).to eq(admin_dashboard_path)
      expect(page).to have_content(I18n.t('devise.sessions.signed_in'))
    end
  else
    it 'prevents signin and shows unauthorized message' do
      expect(current_path).to eq(new_admin_user_session_path)
      expect(page).to have_content(I18n.t('devise.failure.unauthorized_status'))
    end
  end
end
