# frozen_string_literal: true

class CreatePositions < ActiveRecord::Migration[7.0]
  def change
    create_table :positions do |t|
      # NOT CHANGING
      t.references :portfolio_report, null: false, foreign_key: true
      t.integer :uniswap_id
      t.integer :initial_tick
      t.timestamp :initial_timestamp
      t.string :owner # Use relateion
      t.integer :tick_lower
      t.integer :tick_upper
      # CHANGING
      t.decimal :fee_growth_inside_last_x128_0
      t.decimal :fee_growth_inside_last_x128_1
      t.decimal :liquidity
      t.decimal :hold_usd_value
      t.jsonb :liquidity_changes, null: false, default: {}
      t.jsonb :collects, null: false, default: {}
      t.jsonb :liquidity_decreases, null: false, default: {}
      t.jsonb :liquidity_increases, null: false, default: {}
      t.jsonb :token_0, null: false, default: {}
      t.jsonb :token_1, null: false, default: {}
      t.jsonb :pool, null: false, default: {}
      t.jsonb :events, null: false, default: {}
      t.jsonb :fees_claims, null: false, default: {}
      # Кажется, это не надо хранить в базе данных:
      # t.decimal :totalUsdValue
    end

    add_index :positions, %i[uniswap_id portfolio_report_id], unique: true
  end
end
