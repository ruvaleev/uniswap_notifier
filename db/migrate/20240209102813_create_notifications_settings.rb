# frozen_string_literal: true

class CreateNotificationsSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications_settings do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.boolean :out_of_range, null: false, default: true
    end
  end
end
