require "rails_helper"

# Requirement: Abstract print base controller
#
# 以測試用範例子類別驗證 Admin::Print::BaseController 的共通流程。
# 範例子類別的路由與版型只存在於測試中,正式項目由各自的 propose 加入。
RSpec.describe "Admin::Print::BaseController", type: :request do
  let(:tmp_dir) { Rails.root.join("tmp", "print_base_spec") }
  let(:sample_controller) do
    Class.new(Admin::Print::BaseController) do
      prepend_view_path Rails.root.join("spec/fixtures/views")

      def self.name
        "Admin::Print::SampleController"
      end

      private

      def print_template
        "admin/print/sample/preview"
      end

      def build_print_data(rows)
        header, *body = rows
        { header: header, body: body }
      end
    end
  end

  # 先載入正式 routes (Rails 8 為延遲載入),再附加範例子類別的路由。
  # 附加路由不會清除 URL 產生的快取 (formatter),需手動清除,
  # 否則 url_for(action: :preview) 可能找不到剛附加的路由。
  around do |example|
    Rails.application.reload_routes_unless_loaded
    Rails.application.routes.disable_clear_and_finalize = true
    Rails.application.routes.draw do
      namespace :admin do
        get "print/sample", to: "print/sample#show", as: :print_sample
        post "print/sample/preview", to: "print/sample#preview", as: :preview_print_sample
      end
    end
    Rails.application.routes.formatter.clear

    example.run
  ensure
    Rails.application.routes.disable_clear_and_finalize = false
    Rails.application.reload_routes!
  end

  before do
    stub_const("Admin::Print::SampleController", sample_controller)
    FileUtils.mkdir_p(tmp_dir)
  end

  after { FileUtils.rm_rf(tmp_dir) }

  def upload(filename, content)
    path = tmp_dir.join(filename)
    File.write(path, content)
    Rack::Test::UploadedFile.new(path, "application/octet-stream", original_filename: filename)
  end

  context "when signed in as an admin" do
    before { sign_in create(:user), scope: :user }

    describe "GET show (Render upload form)" do
      it "renders an upload form that accepts .xlsx and .csv files" do
        get "/admin/print/sample"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('action="/admin/print/sample/preview"', 'type="file"', 'accept=".xlsx,.csv"')
      end
    end

    describe "POST preview (Generate print preview from uploaded file)" do
      it "parses the file, maps rows to view data and renders the template with the print layout" do
        post "/admin/print/sample/preview", params: { file: upload("data.csv", "name,age\nAmy,30\n") }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("<th>name</th>", "<td>Amy</td>", "<td>30</td>", 'data-action="click->print#print"')
      end
    end

    describe "POST preview (Missing or invalid file)" do
      it "redirects back to the upload form with an error when no file is submitted" do
        post "/admin/print/sample/preview"

        expect(response).to redirect_to("/admin/print/sample")
        expect(flash[:alert]).to eq("請選擇要上傳的檔案")
      end

      it "redirects back to the upload form with an error for an unsupported file type" do
        post "/admin/print/sample/preview", params: { file: upload("data.txt", "hello") }

        expect(response).to redirect_to("/admin/print/sample")
        expect(flash[:alert]).to eq("檔案解析失敗,請確認檔案格式為 .xlsx 或 .csv")
      end

      it "redirects back to the upload form with an error when the file cannot be parsed" do
        post "/admin/print/sample/preview", params: { file: upload("broken.xlsx", "not a zip") }

        expect(response).to redirect_to("/admin/print/sample")
        expect(flash[:alert]).to eq("檔案解析失敗,請確認檔案格式為 .xlsx 或 .csv")
      end
    end
  end

  context "when not signed in" do
    it "redirects to the sign-in page" do
      get "/admin/print/sample"

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
