module Admin
  module Print
    # 列印項目的抽象基底 controller。
    #
    # 提供共通流程:
    #   show    - 渲染上傳表單 (接受 .xlsx / .csv),版型為 admin/print/base/show
    #   preview - 解析上傳檔為 rows,交由子類別轉成 view 資料,以 print layout 渲染列印版型
    #
    # 子類別只需覆寫 print_template 與 build_print_data,並在 routes 加入
    # show (GET) 與 preview (POST) 兩條路由。
    class BaseController < Admin::ApplicationController
      MISSING_FILE_MESSAGE = "請選擇要上傳的檔案".freeze
      PARSE_FAILED_MESSAGE = "檔案解析失敗,請確認檔案格式為 .xlsx 或 .csv".freeze

      before_action :authenticate_user!

      def show
      end

      def preview
        file = params[:file]
        return redirect_to_upload_form(MISSING_FILE_MESSAGE) unless file.respond_to?(:original_filename)

        rows = parse_rows(file)
        return redirect_to_upload_form(PARSE_FAILED_MESSAGE) if rows.nil?

        @print_data = build_print_data(rows)
        render template: print_template, layout: "print"
      end

      private

      # 子類別覆寫:列印版型樣板路徑,例如 "admin/print/roster/preview"。
      def print_template
        raise NotImplementedError, "#{self.class.name} must implement #print_template"
      end

      # 子類別覆寫:將解析後的 rows (Array<Array>) 轉成版型所需的 view 資料,指派給 @print_data。
      def build_print_data(rows)
        raise NotImplementedError, "#{self.class.name} must implement #build_print_data"
      end

      # 解析失敗 (不支援副檔名、檔案毀損等) 時回傳 nil,由 preview 導回上傳表單。
      def parse_rows(file)
        ::Print::FileParser.new(file).rows
      rescue StandardError => e
        Rails.logger.warn("[Print] Failed to parse #{file.original_filename}: #{e.class}: #{e.message}")
        nil
      end

      def redirect_to_upload_form(message)
        redirect_to url_for(action: :show), alert: message
      end
    end
  end
end
