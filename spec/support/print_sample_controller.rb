# frozen_string_literal: true

# 以測試用範例子類別驗證 Admin::Print::BaseController 的共通流程。
# 範例子類別的路由與版型只存在於測試中,正式項目由各自的 propose 加入。
RSpec.shared_context "with print sample controller" do
  let(:print_sample_controller) do
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

  before { stub_const("Admin::Print::SampleController", print_sample_controller) }
end
