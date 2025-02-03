module Admin
  class MembersController < ApplicationController
    before_action :find_member, only: :show

    def index
      @members = Member.all
    end

    def show; end

    private

    def find_member
      @member = Member.find(params[:id])
    end
  end
end
