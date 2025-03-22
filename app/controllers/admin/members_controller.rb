# frozen_string_literal: true

module Admin
  class MembersController < ApplicationController
    before_action :authenticate_admin_user!
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
