# 未登入存取下載格式 (例如 Excel 匯出 .xlsx) 時，導向 HTML 登入頁，
# 而非保留原格式導向 /admin/users/sign_in.xlsx。
class DeviseFailureApp < Devise::FailureApp
  DOWNLOAD_FORMATS = %w[xlsx].freeze

  def skip_format?
    super || DOWNLOAD_FORMATS.include?(request_format.to_s)
  end
end
