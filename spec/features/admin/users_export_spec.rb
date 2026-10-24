# frozen_string_literal: true

require "rails_helper"

RSpec.describe "會員 Excel 匯出", type: :feature do
  let(:current_user) { create(:user, :master, name: "管理員") }
  let!(:wang) { create(:user, :member, name: "王小明", email: "wang@example.com") }

  def exported_rows
    path = Rails.root.join("tmp", "users_export_#{SecureRandom.hex(4)}.xlsx")
    File.binwrite(path, page.driver.response.body)
    Roo::Excelx.new(path.to_s).sheet(0).to_a
  ensure
    FileUtils.rm_f(path)
  end

  before { create(:user, :volunteer, name: "李大華") }

  context "when signed in" do
    before do
      login_as(current_user, scope: :user)
      visit admin_users_path
    end

    it "點擊匯出 Excel 下載 xlsx 檔，欄位依預定順序排列" do
      click_link "匯出 Excel"

      expect(page.response_headers["Content-Type"]).to include("spreadsheetml")
      expect(exported_rows.first).to eq(%w[身份 姓名 身分證字號 性別 出生日期 生肖 地址 電子郵件])
    end

    it "未套用篩選時匯出所有會員" do
      click_link "匯出 Excel"

      names = exported_rows.drop(1).map { |row| row[1] }
      expect(names).to contain_exactly("管理員", "王小明", "李大華")
    end

    it "套用搜尋條件後只匯出符合條件的會員" do
      fill_in "q_name_cont", with: "小明"
      click_button "搜尋"
      click_link "匯出 Excel"

      rows = exported_rows.drop(1)
      expect(rows.size).to eq(1)
      expect(rows.first).to include("會員", "王小明", wang.id_number, "wang@example.com")
    end
  end

  context "when not signed in" do
    it "存取匯出功能會被導向登入頁" do
      visit export_admin_users_path(format: :xlsx)

      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
