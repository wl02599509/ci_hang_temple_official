# frozen_string_literal: true

require "rails_helper"

RSpec.describe "列印作業", type: :feature do
  let(:current_user) { create(:user) }

  describe "列印作業總覽" do
    before { login_as(current_user, scope: :user) }

    it "從側邊欄進入列印作業，該項目顯示為 active" do
      visit admin_root_path
      within(".sidebar-nav") { click_link "列印作業" }

      expect(page).to have_current_path(admin_print_path)
      expect(page).to have_css(".sidebar-nav li.active", text: "列印作業")
    end

    it "尚無列印項目時顯示空狀態" do
      allow(Print::Registry).to receive(:all).and_return([])
      visit admin_print_path

      expect(page).to have_content("目前尚未有任何列印項目。")
    end

    it "有註冊的列印項目時顯示卡片並連結到該項目頁面" do
      allow(Print::Registry).to receive(:all).and_return([
        Print::Definition.new(slug: "member-roster", title: "會員名冊",
                              description: "上傳會員名單,列印格式化名冊", path: "/admin/print/member-roster")
      ])
      visit admin_print_path

      expect(page).to have_link(href: "/admin/print/member-roster")
      expect(page).to have_content("會員名冊")
      expect(page).to have_content("上傳會員名單,列印格式化名冊")
    end
  end

  describe "上傳檔案產生列印預覽" do
    include_context "with print sample controller"

    let(:tmp_dir) { Rails.root.join("tmp", "print_feature_spec") }

    before do
      FileUtils.mkdir_p(tmp_dir)
      login_as(current_user, scope: :user)
      visit "/admin/print/sample"
    end

    after { FileUtils.rm_rf(tmp_dir) }

    def write_file(filename, content)
      tmp_dir.join(filename).tap { |path| File.write(path, content) }
    end

    it "上傳 csv 後以列印版型顯示資料，並提供列印與返回按鈕" do
      attach_file "file", write_file("data.csv", "姓名,年齡\n王小明,30\n")
      click_button "產生列印預覽"

      expect(page).to have_css("th", text: "姓名")
      expect(page).to have_css("td", text: "王小明")
      expect(page).to have_button("列印")
      expect(page).to have_link("返回列印作業", href: admin_print_path)
    end

    it "上傳不支援的檔案類型時回到上傳表單並顯示錯誤" do
      attach_file "file", write_file("data.txt", "hello")
      click_button "產生列印預覽"

      expect(page).to have_current_path("/admin/print/sample")
      expect(page).to have_content("檔案解析失敗,請確認檔案格式為 .xlsx 或 .csv")
    end

    it "未選擇檔案時回到上傳表單並顯示錯誤" do
      click_button "產生列印預覽"

      expect(page).to have_current_path("/admin/print/sample")
      expect(page).to have_content("請選擇要上傳的檔案")
    end

    it "按返回列印作業回到總覽頁" do
      click_link "返回列印作業"

      expect(page).to have_current_path(admin_print_path)
    end

    it "在預覽頁按列印按鈕會呼叫瀏覽器列印", :js do
      attach_file "file", write_file("data.csv", "姓名\n王小明\n")
      click_button "產生列印預覽"
      expect(page).to have_css("td", text: "王小明")

      page.execute_script("window.__printCalled = false; window.print = () => { window.__printCalled = true }")
      click_button "列印"

      expect(page.evaluate_script("window.__printCalled")).to be(true)
    end
  end

  context "when not signed in" do
    it "存取列印作業會被導向登入頁" do
      visit admin_print_path

      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
