require 'rails_helper'

RSpec.describe "Admin::Activities", type: :request do
  let(:user) { create(:user) }

  before { sign_in user, scope: :user }

  describe "GET /admin/activities" do
    before do
      create(:activity, title: "古廟活動", event_date: Date.today - 30)
      create(:activity, title: "新年活動", event_date: Date.today + 30)
    end

    it "returns http success" do
      get admin_activities_path
      expect(response).to have_http_status(:success)
    end

    it "renders activities in descending event_date order" do
      get admin_activities_path
      expect(response.body).to match(/新年活動.*古廟活動/m)
    end

    context "when filtering by title" do
      it "filters activities by partial title match" do
        get admin_activities_path, params: { q: { title_cont: "新年" } }
        expect(response.body).to include("新年活動")
        expect(response.body).not_to include("古廟活動")
      end
    end

    context "when filtering by ROC year" do
      it "filters activities by ROC year (ROC 113 = Gregorian 2024)" do
        create(:activity, title: "2024活動", event_date: Date.new(2024, 6, 15))
        create(:activity, title: "2025活動", event_date: Date.new(2025, 6, 15))
        get admin_activities_path, params: { roc_year: "113" }
        expect(response.body).to include("2024活動")
        expect(response.body).not_to include("2025活動")
      end
    end
  end

  describe "GET /admin/activities/:id" do
    let(:activity) { create(:activity) }

    it "returns http success" do
      get admin_activity_path(activity)
      expect(response).to have_http_status(:success)
    end

    it "displays activity fields" do
      get admin_activity_path(activity)
      expect(response.body).to include(activity.title)
    end
  end

  describe "GET /admin/activities/new" do
    it "returns http success" do
      get new_admin_activity_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/activities" do
    context "with valid params" do
      let(:valid_params) do
        {
          activity: {
            title: "端午節活動",
            description: "慶祝端午節的活動",
            event_date: "2026-06-01",
            registration_start_date: "2026-05-01",
            registration_end_date: "2026-05-20",
            fee: "200.00",
            status: "draft"
          }
        }
      end

      it "creates activity and redirects to index" do
        expect { post admin_activities_path, params: valid_params }
          .to change(Activity, :count).by(1)
        expect(response).to redirect_to(admin_activities_path)
      end

      it "defaults status to draft" do
        post admin_activities_path, params: valid_params
        expect(Activity.last.status).to eq("draft")
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        { activity: { title: "", description: "", fee: "" } }
      end

      it "does not create activity and re-renders form" do
        expect { post admin_activities_path, params: invalid_params }
          .not_to change(Activity, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /admin/activities/:id/edit" do
    let(:activity) { create(:activity) }

    it "returns http success" do
      get edit_admin_activity_path(activity)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/activities/:id" do
    let(:activity) { create(:activity, title: "舊標題") }

    context "with valid params" do
      it "updates activity and redirects to index" do
        patch admin_activity_path(activity), params: { activity: { title: "新標題" } }
        expect(activity.reload.title).to eq("新標題")
        expect(response).to redirect_to(admin_activities_path)
      end
    end

    context "with invalid params" do
      it "re-renders form with errors" do
        patch admin_activity_path(activity), params: { activity: { title: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
