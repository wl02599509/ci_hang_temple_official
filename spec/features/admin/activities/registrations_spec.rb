# frozen_string_literal: true

require "rails_helper"

RSpec.describe "活動報名管理", :js, type: :feature do
  let(:current_user) { create(:user) }
  let(:activity) { create(:activity, :published) }
  let(:other_user) { create(:user) }

  before { login_as(current_user, scope: :user) }

  describe "報名功能" do
    before do
      visit admin_activity_registrations_path(activity)
      click_button "報名"
      fill_in placeholder: "輸入關鍵字搜尋...", with: other_user.name
      find("input[name='user_ids[]'][value='#{other_user.id}']").check
      click_button "確定報名"
    end

    it "搜尋會員並報名後，該會員出現在報名清單中且狀態為待繳費" do
      expect(page).to have_content(other_user.name)
      expect(page).to have_content("待繳費")
    end
  end

  describe "繳費功能" do
    let!(:registration) { create(:activity_registration, activity: activity, user: other_user) }

    before do
      visit admin_activity_registrations_path(activity)
      find("input[type='checkbox'][value='#{registration.id}']").check
      click_button "繳費"
      select "現金", from: "payment_method"
      fill_in "collector", with: "王小明"
      click_button "確定繳費"
    end

    it "選取待繳費的報名並填寫繳費資訊後，狀態變更為已繳費" do
      expect(page).to have_content("已繳費")
    end
  end

  describe "取消報名功能" do
    context "when 取消待繳費的報名" do
      let!(:registration) { create(:activity_registration, activity: activity, user: other_user) }

      before do
        visit admin_activity_registrations_path(activity)
        find("input[type='checkbox'][value='#{registration.id}']").check
        click_button "取消報名"
      end

      it "modal 不顯示退費金額欄位" do
        expect(page).not_to have_field("refund_amount")
      end

      it "填寫取消原因後，報名狀態變更為已取消" do
        fill_in "cancel_reason", with: "臨時有事無法參加"
        click_button "確定取消報名"
        expect(page).to have_content("已取消")
      end
    end

    context "when 取消已繳費的報名" do
      let!(:registration) { create(:activity_registration, :paid, activity: activity, user: other_user) }

      before do
        visit admin_activity_registrations_path(activity)
        find("input[type='checkbox'][value='#{registration.id}']").check
        click_button "取消報名"
      end

      it "modal 出現退費金額欄位" do
        expect(page).to have_field("refund_amount")
      end

      it "填寫退費資訊後，狀態變更為已取消" do
        fill_in "cancel_reason", with: "活動取消，全額退費"
        fill_in "refund_amount", with: "500"
        click_button "確定取消報名"
        expect(page).to have_content("已取消")
      end
    end

    context "when 同時選取已繳費與待繳費的報名" do
      let!(:paid_registration) { create(:activity_registration, :paid, activity: activity, user: other_user) }
      let!(:pending_registration) { create(:activity_registration, activity: activity, user: create(:user)) }

      before do
        visit admin_activity_registrations_path(activity)
        find("input[type='checkbox'][value='#{paid_registration.id}']").check
        find("input[type='checkbox'][value='#{pending_registration.id}']").check
        click_button "取消報名"
      end

      it "modal 顯示未繳費者不套用退費的提醒" do
        expect(page).to have_content("退費金額不會套用於未繳費者")
      end

      it "退費金額只記錄在已繳費的報名" do
        fill_in "cancel_reason", with: "活動延期"
        fill_in "refund_amount", with: "500"
        click_button "確定取消報名"

        expect(page).to have_no_content("待繳費")
        expect(paid_registration.reload.refund_amount).to eq(500)
        expect(pending_registration.reload).to be_cancelled
        expect(pending_registration.refund_amount).to be_nil
      end
    end

    context "when 未填寫取消原因" do
      let!(:registration) { create(:activity_registration, activity: activity, user: other_user) }

      it "無法送出，報名維持待繳費" do
        visit admin_activity_registrations_path(activity)
        find("input[type='checkbox'][value='#{registration.id}']").check
        click_button "取消報名"
        click_button "確定取消報名"

        expect(page).to have_button("確定取消報名")
        expect(registration.reload).to be_pending
      end
    end
  end

  describe "報名列表" do
    it "尚無報名時顯示空狀態" do
      visit admin_activity_registrations_path(activity)

      expect(page).to have_content("目前沒有報名資料")
    end

    it "按返回活動列表回到活動列表" do
      visit admin_activity_registrations_path(activity)
      click_link "返回活動列表"

      expect(page).to have_current_path(admin_activities_path)
    end

    it "未選取任何報名時按繳費或取消報名不會開啟 modal" do
      create(:activity_registration, activity: activity, user: other_user)
      visit admin_activity_registrations_path(activity)

      click_button "繳費"
      click_button "取消報名"

      expect(page).to have_no_button("確定繳費")
      expect(page).to have_no_button("確定取消報名")
    end
  end

  describe "報名 modal 的會員搜尋" do
    before do
      visit admin_activity_registrations_path(activity)
      click_button "報名"
    end

    it "尚未輸入關鍵字時顯示提示" do
      expect(page).to have_content("請輸入關鍵字搜尋會員")
    end

    it "可依身分證字號搜尋會員" do
      fill_in placeholder: "輸入關鍵字搜尋...", with: other_user.id_number

      expect(page).to have_css("input[name='user_ids[]'][value='#{other_user.id}']")
    end

    it "查無符合的會員時顯示提示" do
      fill_in placeholder: "輸入關鍵字搜尋...", with: "不存在的會員"

      expect(page).to have_content("找不到符合的會員")
    end

    it "可一次報名多位會員" do
      third_user = create(:user, name: "#{other_user.name}二")
      fill_in placeholder: "輸入關鍵字搜尋...", with: other_user.name
      find("input[name='user_ids[]'][value='#{other_user.id}']").check
      find("input[name='user_ids[]'][value='#{third_user.id}']").check
      click_button "確定報名"

      expect(page).to have_css("#registrations_table tbody tr", count: 2)
    end

    it "已報名的會員再次報名不會重複建立" do
      create(:activity_registration, activity: activity, user: other_user)
      visit admin_activity_registrations_path(activity)
      click_button "報名"
      fill_in placeholder: "輸入關鍵字搜尋...", with: other_user.name
      find("input[name='user_ids[]'][value='#{other_user.id}']").check
      click_button "確定報名"

      expect(page).to have_no_button("確定報名")
      expect(page).to have_css("#registrations_table tbody tr", count: 1)
    end

    it "按 ✕ 關閉 modal" do
      click_button "✕"

      expect(page).to have_no_button("確定報名")
    end
  end

  describe "繳費的必填檢查與批次繳費" do
    let!(:registration) { create(:activity_registration, activity: activity, user: other_user) }
    let!(:another_registration) { create(:activity_registration, activity: activity, user: create(:user)) }

    before { visit admin_activity_registrations_path(activity) }

    it "未選擇繳費方式或未填收款人時無法送出" do
      find("input[type='checkbox'][value='#{registration.id}']").check
      click_button "繳費"
      fill_in "collector", with: "王小明"
      click_button "確定繳費"

      expect(page).to have_button("確定繳費")
      expect(registration.reload).to be_pending

      select "轉帳", from: "payment_method"
      fill_in "collector", with: ""
      click_button "確定繳費"

      expect(page).to have_button("確定繳費")
      expect(registration.reload).to be_pending
    end

    it "全選後可批次繳費" do
      find("thead input[type='checkbox']").check
      click_button "繳費"
      select "轉帳", from: "payment_method"
      fill_in "collector", with: "王小明"
      click_button "確定繳費"

      expect(page).to have_no_content("待繳費")
      expect([ registration.reload, another_registration.reload ]).to all(be_paid)
      expect(registration.payment_method).to eq("transfer")
      expect(registration.collector).to eq("王小明")
    end
  end
end
