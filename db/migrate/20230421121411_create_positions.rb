# frozen_string_literal: true

class CreatePositions < ActiveRecord::Migration[7.0]
  def change
    create_table :positions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :notification_status, null: false, default: 0
      t.integer :rebalance_threshold_percents, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.integer :fee
      t.integer :tick_lower
      t.integer :tick_upper
      t.string :liquidity
      t.string :pool_address
      t.integer :uniswap_id, null: false

      t.timestamps
    end

    add_index :positions, %i[uniswap_id user_id], unique: true
  end
end
