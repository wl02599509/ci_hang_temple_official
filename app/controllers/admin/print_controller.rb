module Admin
  # 列印作業總覽頁:列出所有已註冊的列印項目 (Print::Registry)。
  # 各列印項目本身繼承 Admin::Print::BaseController,於各自的 propose 中加入。
  class PrintController < ApplicationController
    before_action :authenticate_user!

    def index
      @definitions = ::Print::Registry.all
    end
  end
end
