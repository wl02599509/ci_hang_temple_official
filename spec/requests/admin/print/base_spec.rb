require "rails_helper"

# Requirement: Abstract print base controller
RSpec.describe "Admin::Print::BaseController", type: :request do
  include_context "with print sample controller"

  let(:tmp_dir) { Rails.root.join("tmp", "print_base_spec") }

  before { FileUtils.mkdir_p(tmp_dir) }

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
