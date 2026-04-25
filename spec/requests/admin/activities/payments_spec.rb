require 'rails_helper'

RSpec.describe "Admin::Activities::Payments", type: :request do
  let(:admin_user) { create(:user) }
  let(:activity) { create(:activity) }

  before { sign_in admin_user, scope: :user }

  describe "POST /admin/activities/:activity_id/registrations/pay" do
    context "when batch payment is successful" do
      let!(:first_pending_reg) { create(:activity_registration, activity: activity, user: create(:user), status: :pending) }
      let!(:second_pending_reg) { create(:activity_registration, activity: activity, user: create(:user), status: :pending) }

      before do
        post pay_admin_activity_registrations_path(activity),
          params: {
            registration_ids: [ first_pending_reg.id, second_pending_reg.id ],
            payment_method: "cash",
            collector: "王管理員"
          },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end

      it "marks pending registrations as paid with payment details" do
        first_pending_reg.reload
        expect(first_pending_reg.status).to eq("paid")
        expect(first_pending_reg.payment_method).to eq("cash")
        expect(first_pending_reg.collector).to eq("王管理員")
        expect(first_pending_reg.paid_at).to be_present
      end
    end

    context "when already paid or cancelled are skipped" do
      let!(:paid_reg) do
        create(:activity_registration, activity: activity, user: create(:user), status: :paid,
          payment_method: :cash, collector: "Original", paid_at: 1.day.ago)
      end
      let!(:cancelled_reg) do
        create(:activity_registration, activity: activity, user: create(:user), status: :cancelled,
          cancel_reason: "reason", cancelled_at: Time.current)
      end

      it "skips already paid registrations" do
        post pay_admin_activity_registrations_path(activity),
          params: { registration_ids: [ paid_reg.id ], payment_method: "transfer", collector: "新收款人" },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(paid_reg.reload.collector).to eq("Original")
        expect(paid_reg.reload.status).to eq("paid")
      end

      it "skips cancelled registrations" do
        post pay_admin_activity_registrations_path(activity),
          params: { registration_ids: [ cancelled_reg.id ], payment_method: "cash", collector: "收款人" },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(cancelled_reg.reload.status).to eq("cancelled")
      end
    end
  end
end
