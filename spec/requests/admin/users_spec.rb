require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  # Member write actions are restricted to 宮主 (master), so the acting admin in
  # the CRUD examples below signs in as a master.
  let(:admin) { create(:user, :master) }

  before { sign_in admin, scope: :user }

  def valid_member_params
    attributes_for(:user).slice(
      :id_number, :name, :phone_number, :birth_date, :address, :email, :status
    )
  end

  # Requirement: Admin creates a member from the member list
  describe "POST /admin/users (Admin creates a member from the member list)" do
    it "creates a member and redirects to the list" do
      expect {
        post admin_users_path, params: { user: valid_member_params }
      }.to change(User, :count).by(1)
      expect(response).to redirect_to(admin_users_path)
    end

    it "stores an auto-generated password the admin never supplied" do
      post admin_users_path, params: { user: valid_member_params }
      created = User.order(:created_at).last
      expect(created.encrypted_password).to be_present
      expect(created.valid_password?("password123")).to be(false)
    end

    it "re-renders the form with 422 on duplicate id_number and creates no record" do
      existing = create(:user)

      expect {
        post admin_users_path, params: { user: valid_member_params.merge(id_number: existing.id_number) }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  # Requirement: Admin views a member detail page
  describe "GET /admin/users/:id (Admin views a member detail page)" do
    let(:member) { create(:user) }

    it "returns 200 and shows the member's basic data without a password field" do
      get admin_user_path(member)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(member.name)
      expect(response.body).to include(member.id_number)
      expect(response.body).not_to match(/type=["']password["']/)
    end
  end

  # Requirement: Admin edits an existing member
  describe "PATCH /admin/users/:id (Admin edits an existing member)" do
    let(:member) { create(:user, name: "舊名字") }

    it "updates basic data without a password and redirects to the list" do
      patch admin_user_path(member), params: { user: { name: "新名字" } }

      expect(response).to redirect_to(admin_users_path)
      expect(member.reload.name).to eq("新名字")
    end

    it "re-renders the edit form with 422 on invalid data" do
      patch admin_user_path(member), params: { user: { name: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(member.reload.name).to eq("舊名字")
    end
  end

  # Requirement: Admin deletes a member with a self-deletion guard
  describe "DELETE /admin/users/:id (Admin deletes a member with a self-deletion guard)" do
    it "deletes another member and redirects to the list" do
      member = create(:user)

      expect {
        delete admin_user_path(member)
      }.to change(User, :count).by(-1)

      expect(response).to redirect_to(admin_users_path)
    end

    it "includes the member's status, name and id_number in the success message" do
      member = create(:user, :member, name: "王小明")
      delete admin_user_path(member)
      expect(flash[:notice]).to eq("會員王小明(#{member.id_number})資料已刪除")
    end

    it "blocks deleting one's own signed-in account and shows an error" do
      expect {
        delete admin_user_path(admin)
      }.not_to change(User, :count)
      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to be_present
    end
  end

  # Requirement: Authorization restricts member write actions to 宮主 (master)
  describe "authorization for non-master users" do
    let(:non_master) { create(:user, :normal) }

    before { sign_in non_master, scope: :user }

    it "denies GET new and redirects to the list with an alert" do
      get new_admin_user_path
      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to eq(I18n.t("pundit.not_authorized"))
    end

    it "denies POST create, creates no record, and redirects with an alert" do
      expect {
        post admin_users_path, params: { user: valid_member_params }
      }.not_to change(User, :count)
      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to eq(I18n.t("pundit.not_authorized"))
    end

    it "denies GET edit and redirects to the list with an alert" do
      member = create(:user)
      get edit_admin_user_path(member)
      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to eq(I18n.t("pundit.not_authorized"))
    end

    it "denies PATCH update, leaves the record unchanged, and redirects with an alert" do
      member = create(:user, name: "原名字")
      patch admin_user_path(member), params: { user: { name: "改後名字" } }
      expect(member.reload.name).to eq("原名字")
      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to eq(I18n.t("pundit.not_authorized"))
    end

    it "denies DELETE destroy, deletes no record, and redirects with an alert" do
      member = create(:user)
      expect { delete admin_user_path(member) }.not_to change(User, :count)
      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to eq(I18n.t("pundit.not_authorized"))
    end

    it "still allows reading the member list" do
      get admin_users_path
      expect(response).to have_http_status(:success)
    end

    it "still allows viewing a member detail page" do
      member = create(:user)
      get admin_user_path(member)
      expect(response).to have_http_status(:success)
    end

    it "still allows the Excel export" do
      create(:user)
      get export_admin_users_path(format: :xlsx)
      expect(response).to have_http_status(:success)
    end
  end

  # Requirement: button visibility scenarios for create / edit / delete
  describe "member list button visibility" do
    let(:new_label) { I18n.t("admin.users.actions.new") }
    let(:edit_label) { I18n.t("admin.users.actions.edit") }
    let(:delete_label) { I18n.t("admin.users.actions.delete") }

    context "when the signed-in user is a master" do
      it "shows the 新增會員, 編輯 and 刪除 buttons" do
        create(:user)
        get admin_users_path

        expect(response.body).to include(new_label)
        expect(response.body).to include(edit_label)
        expect(response.body).to include(delete_label)
      end
    end

    context "when the signed-in user is not a master" do
      let(:non_master) { create(:user, :normal) }

      before { sign_in non_master, scope: :user }

      it "hides the 新增會員, 編輯 and 刪除 buttons but keeps 檢視" do
        get admin_users_path

        [ new_label, edit_label, delete_label ].each { |label| expect(response.body).not_to include(label) }
        expect(response.body).to include(I18n.t("admin.users.actions.view"))
      end
    end
  end

  # Requirement: button visibility on the member detail page
  describe "member detail page button visibility" do
    let(:edit_label) { I18n.t("admin.users.actions.edit") }
    let(:member) { create(:user) }

    context "when the signed-in user is a master" do
      it "shows the 編輯 button on the detail page" do
        get admin_user_path(member)
        expect(response.body).to include(edit_label)
      end
    end

    context "when the signed-in user is not a master" do
      let(:non_master) { create(:user, :normal) }

      before { sign_in non_master, scope: :user }

      it "hides the 編輯 button on the detail page" do
        get admin_user_path(member)
        expect(response.body).not_to include(edit_label)
      end
    end
  end
end
