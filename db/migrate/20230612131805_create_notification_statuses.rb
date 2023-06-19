# frozen_string_literal: true

class CreateNotificationStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :notification_statuses do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :uniswap_id, null: false
      t.datetime :last_sent_at, index: true

      t.timestamps
    end

    add_index :notification_statuses, %i[uniswap_id user_id], unique: true
  end
end
