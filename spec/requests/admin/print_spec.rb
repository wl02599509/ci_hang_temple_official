require "rails_helper"

RSpec.describe "Admin::Print", type: :request do
  # Requirement: Print overview page
  describe "GET /admin/print (Print overview page)" do
    context "when signed in as an admin" do
      before { sign_in create(:user), scope: :user }

      let(:definitions) do
        [
          Print::Definition.new(slug: "roster", title: "會員名冊", description: "名冊說明", path: "/admin/print/roster"),
          Print::Definition.new(slug: "receipt", title: "繳費單", description: "繳費單說明", path: "/admin/print/receipt")
        ]
      end

      it "returns 200 and renders one card per registered item linking to its path" do
        allow(Print::Registry).to receive(:all).and_return(definitions)

        get "/admin/print"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("會員名冊", "繳費單", 'href="/admin/print/roster"', 'href="/admin/print/receipt"')
      end

      it "returns 200 and shows an empty state when no items are registered" do
        allow(Print::Registry).to receive(:all).and_return([])

        get "/admin/print"

        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include('class="print-card"')
        expect(response.body).to include("尚未")
      end
    end

    # Requirement: Print sidebar entry (the sidebar links to /admin/print on every admin page)
    context "when not signed in" do
      it "redirects to the sign-in page" do
        get "/admin/print"

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
