# frozen_string_literal: true

class RenameTableNameAdminMembersIntoUsers < ActiveRecord::Migration[8.0]
  def change
    rename_table :admin_members, :users
  end
end
