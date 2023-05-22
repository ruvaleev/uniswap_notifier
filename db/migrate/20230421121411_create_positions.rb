# frozen_string_literal: true

class CreatePositions < ActiveRecord::Migration[7.0]
  def change
    create_table :positions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :notification_status, null: false, default: 0
      t.integer :rebalance_threshold_percents, null: false, default: 0
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
