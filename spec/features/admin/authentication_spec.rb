# frozen_string_literal: true

require "rails_helper"

RSpec.describe "登出與忘記密碼", type: :feature do
  let(:user) { create(:user, email: "user@example.com") }

  describe "登出" do
    before do
      login_as(user, scope: :user)
      visit admin_root_path
    end

    it "按登出後顯示成功訊息，並改為顯示登入按鈕" do
      click_button "登出"

      expect(page).to have_content("成功登出")
      expect(page).to have_link("登入", href: new_user_session_path)
      expect(page).not_to have_css(".admin-sidebar")
    end

    it "登出後無法再進入需要登入的頁面" do
      click_button "登出"
      visit admin_users_path

      expect(page).to have_current_path(new_user_session_path)
    end
  end

  describe "忘記密碼" do
    before { ActionMailer::Base.deliveries.clear }

    def reset_password_token_from(mail)
      mail.body.encoded[/reset_password_token=([^"&\s]+)/, 1]
    end

    it "從登入頁進入忘記密碼，輸入身分證字號後寄出重設密碼信" do
      visit new_user_session_path
      click_link "忘記密碼？"
      fill_in "user_id_number", with: user.id_number
      click_button "發送重設密碼指示"

      expect(page).to have_content("您將在幾分鐘內收到一封包含重設密碼指示的電子郵件。")
      expect(ActionMailer::Base.deliveries.last.to).to eq([ "user@example.com" ])
    end

    it "透過重設密碼信的連結設定新密碼後，可用新密碼登入" do
      visit new_user_password_path
      fill_in "user_id_number", with: user.id_number
      click_button "發送重設密碼指示"

      token = reset_password_token_from(ActionMailer::Base.deliveries.last)
      visit edit_user_password_path(reset_password_token: token)
      fill_in "user_password", with: "newpassword456"
      fill_in "user_password_confirmation", with: "newpassword456"
      click_button "變更密碼"

      expect(user.reload.valid_password?("newpassword456")).to be(true)

      Capybara.reset_sessions!
      visit new_user_session_path
      fill_in "user_id_number", with: user.id_number
      fill_in "user_password", with: "newpassword456"
      click_button "登入"

      expect(page).to have_content("成功登入")
    end

    it "變更密碼後導向後台首頁並顯示成功訊息" do
      visit new_user_password_path
      fill_in "user_id_number", with: user.id_number
      click_button "發送重設密碼指示"

      token = reset_password_token_from(ActionMailer::Base.deliveries.last)
      visit edit_user_password_path(reset_password_token: token)
      fill_in "user_password", with: "newpassword456"
      fill_in "user_password_confirmation", with: "newpassword456"
      click_button "變更密碼"

      expect(page).to have_current_path(admin_root_path)
      expect(page).to have_content("您的密碼已成功變更。您現在已登入。")
    end

    it "輸入不存在的身分證字號時顯示錯誤" do
      visit new_user_password_path
      fill_in "user_id_number", with: "A123456789"
      click_button "發送重設密碼指示"

      expect(page).to have_css(".login-form")
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end
end
