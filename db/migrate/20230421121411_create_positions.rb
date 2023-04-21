# frozen_string_literal: true

class CreatePositions < ActiveRecord::Migration[7.0]
  def change
    create_table :positions do |t|
      t.references :from_currency, null: false, foreign_key: { to_table: :currencies }
      t.references :to_currency, null: false, foreign_key: { to_table: :currencies }
      t.decimal :max_price, null: false
      t.decimal :min_price, null: false
      t.integer :notification_status, null: false, default: 0
      t.integer :rebalance_threshold_percents, null: false, default: 0
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
