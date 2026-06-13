require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  let(:admin) { create(:user) }

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
end
