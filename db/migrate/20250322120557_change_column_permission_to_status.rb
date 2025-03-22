# frozen_string_literal: true

class ChangeColumnPermissionToStatus < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :permission, :status
    change_column_default :users, :status, from: 'member', to: 'general'
  end
end
