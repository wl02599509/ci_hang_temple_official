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
  end
end
