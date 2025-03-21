# frozen_string_literal: true

class AddNewColumnPermissionToAdminMembers < ActiveRecord::Migration[8.0]
  def change
    add_column :admin_members, :permission, :string, default: 'member', null: false
  end
end
