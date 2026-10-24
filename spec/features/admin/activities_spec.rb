# frozen_string_literal: true

require "rails_helper"

RSpec.describe "活動管理", type: :feature do
  let(:current_user) { create(:user) }

  before { login_as(current_user, scope: :user) }

  def fill_in_activity_form(title: "中元普渡法會", event_date: "2026-08-20",
                            start_date: "2026-07-01", end_date: "2026-07-31")
    fill_in "activity_title", with: title
    fill_in "activity_description", with: "農曆七月中元普渡"
    fill_in "activity_event_date", with: event_date
    fill_in "activity_registration_start_date", with: start_date
    fill_in "activity_registration_end_date", with: end_date
    fill_in "activity_fee", with: "1200"
  end

  describe "活動列表" do
    let!(:newer) { create(:activity, :published, title: "秋季祭典", event_date: Date.new(2025, 9, 1)) }

    before do
      create(:activity, title: "春季祈福", event_date: Date.new(2024, 3, 1))
      visit admin_activities_path
    end

    it "依活動日期由新到舊排列，並顯示主題、日期、狀態與費用" do
      titles = all("tbody tr td:first-child").map(&:text)
      expect(titles).to eq(%w[秋季祭典 春季祈福])

      within("tr", text: "秋季祭典") do
        expect(page).to have_content("2025-09-01")
        expect(page).to have_content("NT$ 500")
      end
    end

    it "每列提供編輯、檢視、報名與繳費按鈕並可進入對應頁面" do
      within("tr", text: "秋季祭典") { click_link "檢視" }
      expect(page).to have_current_path(admin_activity_path(newer))

      visit admin_activities_path
      within("tr", text: "秋季祭典") { click_link "編輯" }
      expect(page).to have_current_path(edit_admin_activity_path(newer))

      visit admin_activities_path
      within("tr", text: "秋季祭典") { click_link "報名與繳費" }
      expect(page).to have_current_path(admin_activity_registrations_path(newer))
    end

    it "依活動主題部分符合搜尋" do
      fill_in "q_title_cont", with: "祭典"
      click_button "搜尋"

      expect(page).to have_content("秋季祭典")
      expect(page).not_to have_content("春季祈福")
    end

    it "依民國年份篩選（民國 113 年 = 西元 2024 年）" do
      fill_in "roc_year", with: "113"
      click_button "搜尋"

      expect(page).to have_content("春季祈福")
      expect(page).not_to have_content("秋季祭典")
    end

    it "查無資料時顯示空狀態，按清除後顯示全部活動" do
      fill_in "q_title_cont", with: "不存在的活動"
      click_button "搜尋"
      expect(page).to have_content("目前沒有活動資料")

      click_link "清除"
      expect(page).to have_content("秋季祭典")
      expect(page).to have_content("春季祈福")
    end
  end

  describe "新增活動" do
    before do
      visit admin_activities_path
      click_link "新增活動"
    end

    it "填寫完整資料後建立活動，預設為草稿並出現在列表" do
      fill_in_activity_form
      click_button "儲存"

      expect(page).to have_current_path(admin_activities_path)
      within("tr", text: "中元普渡法會") do
        expect(page).to have_content("2026-08-20")
        expect(page).to have_content("NT$ 1,200")
      end
      expect(Activity.find_by!(title: "中元普渡法會")).to be_draft
    end

    it "可上傳活動照片並在活動詳細頁顯示" do
      fill_in_activity_form
      attach_file "activity_photos", Rails.root.join("spec/fixtures/files/photo.png")
      click_button "儲存"

      visit admin_activity_path(Activity.find_by!(title: "中元普渡法會"))
      expect(page).to have_content("活動照片")
      expect(page).to have_css("img[src*='photo.png']")
    end

    it "必填欄位空白時留在表單並顯示錯誤" do
      expect { click_button "儲存" }.not_to change(Activity, :count)

      expect(page).to have_css("h2", text: "新增活動")
      expect(page).to have_css(".alert-error")
    end

    it "報名截止日期早於開始日期時顯示錯誤" do
      fill_in_activity_form(start_date: "2026-07-31", end_date: "2026-07-01")

      expect { click_button "儲存" }.not_to change(Activity, :count)
      expect(page).to have_content("必須在報名開始日期之後")
    end

    it "按取消回到活動列表" do
      click_link "取消"

      expect(page).to have_current_path(admin_activities_path)
    end
  end

  describe "編輯活動" do
    let!(:activity) { create(:activity, title: "春季祈福") }

    before { visit edit_admin_activity_path(activity) }

    it "修改資料並發布後，列表顯示新主題與已發布狀態" do
      fill_in "activity_title", with: "春季祈福法會"
      select I18n.t("activerecord.attributes.activity.statuses.published"), from: "activity_status"
      click_button "儲存"

      expect(page).to have_current_path(admin_activities_path)
      expect(page).to have_content("春季祈福法會")
      expect(activity.reload).to be_published
    end

    it "資料不合法時留在編輯表單並顯示錯誤" do
      fill_in "activity_title", with: ""
      click_button "儲存"

      expect(page).to have_css(".alert-error")
      expect(activity.reload.title).to eq("春季祈福")
    end

    context "when 活動已有照片" do
      let!(:activity) do
        create(:activity).tap do |a|
          a.photos.attach(io: File.open(Rails.root.join("spec/fixtures/files/photo.png")),
                          filename: "photo.png", content_type: "image/png")
        end
      end

      it "顯示目前照片" do
        expect(page).to have_content("目前照片")
        expect(page).to have_css("img[src*='photo.png']")
      end

      it "可刪除單張照片" do
        pending "刪除按鈕送出 DELETE 至 rails_blob_path，但 ActiveStorage 未提供此路由"

        click_button "刪除"
        expect(activity.reload.photos).not_to be_attached
      end
    end
  end

  describe "檢視活動" do
    let!(:activity) { create(:activity, :with_notes, title: "秋季祭典", fee: "800") }

    before { visit admin_activity_path(activity) }

    it "顯示活動所有欄位" do
      expect(page).to have_css("h2", text: "秋季祭典")
      expect(page).to have_content(activity.description)
      expect(page).to have_content(activity.notes)
      expect(page).to have_content(activity.event_date.strftime("%Y-%m-%d"))
      expect(page).to have_content("NT$ 800")
    end

    it "可進入編輯頁或返回列表" do
      click_link "編輯"
      expect(page).to have_current_path(edit_admin_activity_path(activity))

      visit admin_activity_path(activity)
      click_link "返回列表"
      expect(page).to have_current_path(admin_activities_path)
    end
  end

  context "when not signed in" do
    before { logout(:user) }

    it "存取活動列表會被導向登入頁" do
      visit admin_activities_path

      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
