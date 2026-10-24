# frozen_string_literal: true

require "rails_helper"

RSpec.describe "會員管理", type: :feature do
  let(:master) { create(:user, :master) }

  def row_for(user)
    find("tr", text: user.id_number)
  end

  describe "宮主操作" do
    before { login_as(master, scope: :user) }

    describe "新增會員" do
      before do
        visit admin_users_path
        click_link "新增會員"
      end

      it "填寫完整資料後建立會員，回到列表並顯示成功訊息" do
        id_number = FactoryBotHelpers.generate_valid_twid
        fill_in "user_id_number", with: id_number
        fill_in "user_name", with: "王小明"
        fill_in "user_phone_number", with: "0912345678"
        fill_in "user_birth_date", with: "1990-01-01"
        fill_in "user_address", with: "台北市中正區重慶南路一段 1 號"
        select "會員", from: "user_status"
        click_button "儲存"

        created = User.find_by!(name: "王小明")
        expect(page).to have_current_path(admin_users_path)
        expect(page).to have_content("會員王小明(#{created.id_number})資料已建立")
        expect(row_for(created)).to have_content("王小明")
      end

      it "身分證字號以大寫儲存與顯示" do
        id_number = FactoryBotHelpers.generate_valid_twid.upcase
        fill_in "user_id_number", with: id_number.downcase
        fill_in "user_name", with: "王小明"
        fill_in "user_phone_number", with: "0912345678"
        fill_in "user_birth_date", with: "1990-01-01"
        fill_in "user_address", with: "台北市中正區重慶南路一段 1 號"
        click_button "儲存"

        expect(page).to have_css("td", text: id_number, exact_text: true)
      end

      it "必填欄位空白時留在表單並顯示錯誤，且不建立會員" do
        expect {
          fill_in "user_name", with: ""
          click_button "儲存"
        }.not_to change(User, :count)

        expect(page).to have_css("h2", text: "新增會員")
        expect(page).to have_css(".alert-error")
      end

      it "按取消回到會員列表" do
        click_link "取消"

        expect(page).to have_current_path(admin_users_path)
      end
    end

    describe "檢視會員" do
      let!(:member) { create(:user, :member, email: "member@example.com") }

      it "從列表點選檢視，顯示會員基本資料與電子郵件" do
        visit admin_users_path
        within(row_for(member)) { click_link "檢視" }

        expect(page).to have_current_path(admin_user_path(member))
        expect(page).to have_content(member.name)
        expect(page).to have_content(member.id_number)
        expect(page).to have_content("member@example.com")
        expect(page).to have_link("編輯", href: edit_admin_user_path(member))
      end

      it "按返回回到會員列表" do
        visit admin_user_path(member)
        click_link "返回列表"

        expect(page).to have_current_path(admin_users_path)
      end
    end

    describe "編輯會員" do
      let!(:member) { create(:user, :member) }

      before do
        visit admin_users_path
        within(row_for(member)) { click_link "編輯" }
      end

      it "修改資料後儲存，回到列表並顯示更新後的資料" do
        fill_in "user_name", with: "李大華"
        click_button "儲存"

        expect(page).to have_current_path(admin_users_path)
        expect(page).to have_content("會員李大華(#{member.id_number})資料已更新")
        expect(row_for(member)).to have_content("李大華")
      end

      it "資料不合法時留在編輯表單並顯示錯誤" do
        fill_in "user_address", with: ""
        click_button "儲存"

        expect(page).to have_css("h2", text: "編輯會員")
        expect(page).to have_css(".alert-error")
        expect(member.reload.address).to be_present
      end
    end

    describe "刪除會員" do
      let!(:member) { create(:user, :member) }

      it "刪除其他會員後，該會員從列表消失並顯示成功訊息" do
        visit admin_users_path
        within(row_for(member)) { click_button "刪除" }

        expect(page).to have_content("會員#{member.name}(#{member.id_number})資料已刪除")
        expect(page).to have_no_css("tbody tr", text: member.id_number)
      end

      it "無法刪除自己目前登入中的帳號" do
        visit admin_users_path
        within(row_for(master)) { click_button "刪除" }

        expect(page).to have_content("無法刪除自己目前登入中的帳號")
        expect(row_for(master)).to be_present
      end
    end
  end

  describe "刪除會員的確認對話框", :js do
    let!(:member) { create(:user, :member) }

    before { login_as(master, scope: :user) }

    it "接受確認後刪除會員" do
      visit admin_users_path
      accept_confirm("確定要刪除「#{member.name}」嗎？") do
        within(row_for(member)) { click_button "刪除" }
      end

      expect(page).to have_content("資料已刪除")
      expect(User.exists?(member.id)).to be(false)
    end

    it "取消確認後不刪除會員" do
      visit admin_users_path
      dismiss_confirm do
        within(row_for(member)) { click_button "刪除" }
      end

      expect(row_for(member)).to be_present
      expect(User.exists?(member.id)).to be(true)
    end
  end

  describe "非宮主的權限" do
    let(:volunteer) { create(:user, :volunteer) }
    let!(:member) { create(:user, :member) }

    before { login_as(volunteer, scope: :user) }

    it "列表只顯示檢視按鈕，不顯示新增、編輯、刪除" do
      visit admin_users_path

      expect(page).not_to have_link("新增會員")
      within(row_for(member)) do
        expect(page).to have_link("檢視")
        expect(page).not_to have_link("編輯")
        expect(page).not_to have_button("刪除")
      end
    end

    it "會員詳細頁不顯示編輯按鈕" do
      visit admin_user_path(member)

      expect(page).to have_content(member.name)
      expect(page).not_to have_link("編輯")
    end

    it "直接進入新增頁會被導回列表並顯示無權限訊息" do
      visit new_admin_user_path

      expect(page).to have_current_path(admin_users_path)
      expect(page).to have_content("您沒有執行此操作的權限")
    end

    it "直接進入編輯頁會被導回列表並顯示無權限訊息" do
      visit edit_admin_user_path(member)

      expect(page).to have_current_path(admin_users_path)
      expect(page).to have_content("您沒有執行此操作的權限")
    end
  end

  describe "會員列表" do
    before { login_as(master, scope: :user) }

    it "表格不顯示電子郵件欄位" do
      create(:user, email: "hidden@example.com")
      visit admin_users_path

      expect(page).not_to have_css("th", text: "電子郵件")
      expect(page).not_to have_content("hidden@example.com")
    end

    it "會員超過一頁時顯示分頁並可切換頁面" do
      create_list(:user, Pagy.options[:limit])
      visit admin_users_path

      expect(page).to have_css(".pagination-wrap")
      within(".pagination-wrap") { click_link "2" }
      expect(page).to have_css("tbody tr", minimum: 1)
    end
  end

  describe "會員搜尋" do
    let!(:wang) { create(:user, :member, name: "王小明") }
    let!(:lee) { create(:user, :volunteer, name: "李大華") }

    before do
      login_as(master, scope: :user)
      visit admin_users_path
    end

    it "依姓名部分符合搜尋" do
      fill_in "q_name_cont", with: "小明"
      click_button "搜尋"

      expect(page).to have_content(wang.id_number)
      expect(page).not_to have_content(lee.id_number)
    end

    it "依身分證字號開頭搜尋" do
      fill_in "q_id_number_start", with: lee.id_number[0, 5]
      click_button "搜尋"

      expect(page).to have_content(lee.id_number)
    end

    it "依身份篩選" do
      select "志工", from: "q_status_eq"
      click_button "搜尋"

      expect(page).to have_content(lee.id_number)
      expect(page).not_to have_content(wang.id_number)
    end

    it "依性別篩選" do
      sex_label = I18n.t("activerecord.attributes.user.sexes.#{wang.sex}")
      select sex_label, from: "q_sex_eq"
      click_button "搜尋"

      User.where(sex: wang.sex).find_each { |u| expect(page).to have_content(u.id_number) }
      User.where.not(sex: wang.sex).find_each { |u| expect(page).not_to have_content(u.id_number) }
    end

    it "依生肖篩選" do
      wang.update!(zodiac: :dragon)
      select "龍", from: "q_zodiac_eq"
      click_button "搜尋"

      expect(page).to have_content(wang.id_number)
      expect(page).not_to have_content(lee.id_number)
    end

    it "查無資料時顯示空狀態並隱藏匯出按鈕" do
      fill_in "q_name_cont", with: "不存在的名字"
      click_button "搜尋"

      expect(page).to have_content("目前沒有會員資料")
      expect(page).not_to have_link("匯出 Excel")
    end

    it "清除搜尋條件後顯示全部會員" do
      fill_in "q_name_cont", with: "小明"
      click_button "搜尋"
      click_link "清除搜尋條件"

      expect(page).to have_content(wang.id_number)
      expect(page).to have_content(lee.id_number)
    end
  end
end
