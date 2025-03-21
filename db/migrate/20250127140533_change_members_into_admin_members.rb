# frozen_string_literal: true

class ChangeMembersIntoAdminMembers < ActiveRecord::Migration[8.0]
  def change
    rename_table :members, :admin_members
  end
end
