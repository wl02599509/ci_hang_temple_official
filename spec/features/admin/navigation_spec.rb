# frozen_string_literal: true

require "rails_helper"

RSpec.describe "後台導覽", type: :feature do
  let(:current_user) { create(:user, :master, name: "王小明") }

  before do
    login_as(current_user, scope: :user)
    visit admin_root_path
  end

  it "登入後顯示儀表板與使用者問候" do
    expect(page).to have_content("儀表板總覽")
    expect(page).to have_css(".user-name", text: "王小明")
    expect(page).to have_css(".sidebar-nav li.active", text: "儀表板")
  end

  {
    "會員管理" => [ :admin_users_path, "會員列表" ],
    "活動管理" => [ :admin_activities_path, "活動管理" ],
    "列印作業" => [ :admin_print_path, "列印作業" ]
  }.each do |menu, (path_helper, heading)|
    it "點擊側邊欄「#{menu}」進入對應頁面並標示為 active" do
      within(".sidebar-nav") { click_link menu }

      expect(page).to have_current_path(public_send(path_helper))
      expect(page).to have_css("h2", text: heading)
      expect(page).to have_css(".sidebar-nav li.active", text: menu)
    end
  end
end
