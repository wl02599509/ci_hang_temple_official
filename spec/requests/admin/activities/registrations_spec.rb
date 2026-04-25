require 'rails_helper'

RSpec.describe "Admin::Activities::Registrations", type: :request do
  let(:admin_user) { create(:user) }
  let(:activity) { create(:activity) }

  before { sign_in admin_user, scope: :user }

  describe "GET /admin/activities/:activity_id/registrations" do
    let(:member) { create(:user) }

    before { create(:activity_registration, activity: activity, user: member) }

    it "returns http success" do
      get admin_activity_registrations_path(activity)
      expect(response).to have_http_status(:success)
    end

    it "displays registered users" do
      get admin_activity_registrations_path(activity)
      expect(response.body).to include(member.name)
    end
  end

  describe "POST /admin/activities/:activity_id/registrations" do
    let(:first_registrant) { create(:user) }
    let(:second_registrant) { create(:user) }

    context "when registering new users via modal" do
      before do
        post admin_activity_registrations_path(activity),
          params: { user_ids: [ first_registrant.id, second_registrant.id ] },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end

      it "creates registrations with pending status" do
        regs = ActivityRegistration.where(activity: activity)
        expect(regs.count).to eq(2)
        expect(regs.last.status).to eq("pending")
      end
    end

    context "when already registered users are skipped" do
      before do
        create(:activity_registration, activity: activity, user: first_registrant, status: :pending)
        post admin_activity_registrations_path(activity),
          params: { user_ids: [ first_registrant.id, second_registrant.id ] },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end

      it "skips already active registrations" do
        expect(ActivityRegistration.where(activity: activity).count).to eq(2)
      end
    end
  end

  describe "POST /admin/activities/:activity_id/registrations/cancel" do
    let!(:pending_reg) { create(:activity_registration, activity: activity, user: create(:user), status: :pending) }
    let!(:paid_reg) do
      create(:activity_registration, activity: activity, user: create(:user), status: :paid,
        payment_method: :cash, collector: "Test", paid_at: Time.current)
    end
    let!(:cancelled_reg) do
      create(:activity_registration, activity: activity, user: create(:user), status: :cancelled,
        cancel_reason: "already cancelled", cancelled_at: Time.current)
    end

    context "when cancelling pending registrations" do
      before do
        post cancel_admin_activity_registrations_path(activity),
          params: { registration_ids: [ pending_reg.id ], cancel_reason: "活動取消" },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end

      it "sets status to cancelled with cancel_reason and cancelled_at" do
        pending_reg.reload
        expect(pending_reg.status).to eq("cancelled")
        expect(pending_reg.cancel_reason).to eq("活動取消")
        expect(pending_reg.cancelled_at).to be_present
        expect(pending_reg.refund_amount).to be_nil
      end
    end

    context "when cancelling paid registrations with refund" do
      before do
        post cancel_admin_activity_registrations_path(activity),
          params: { registration_ids: [ paid_reg.id ], cancel_reason: "退費取消", refund_amount: "150.00" },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end

      it "records refund_amount and refunded_at for paid registrations" do
        paid_reg.reload
        expect(paid_reg.status).to eq("cancelled")
        expect(paid_reg.refund_amount).to eq(150.00)
        expect(paid_reg.refunded_at).to be_present
      end
    end

    context "with mixed selection (paid and pending)" do
      before do
        post cancel_admin_activity_registrations_path(activity),
          params: { registration_ids: [ pending_reg.id, paid_reg.id ], cancel_reason: "混選取消", refund_amount: "100.00" },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end

      it "records refund only for paid registrations" do
        pending_reg.reload
        paid_reg.reload
        expect(pending_reg.refund_amount).to be_nil
        expect(paid_reg.refund_amount).to eq(100.00)
      end
    end

    context "when already cancelled registrations are ignored" do
      it "does not update already-cancelled registrations" do
        original_cancel_reason = cancelled_reg.cancel_reason
        post cancel_admin_activity_registrations_path(activity),
          params: { registration_ids: [ cancelled_reg.id ], cancel_reason: "新原因" },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(cancelled_reg.reload.cancel_reason).to eq(original_cancel_reason)
      end
    end
  end
end
