# frozen_string_literal: true

class CreatePositionsCoins < ActiveRecord::Migration[7.0]
  def up
    safety_assured do
      execute <<-SQL
        CREATE TYPE positions_coins_number AS ENUM ('0', '1')
      SQL
    end

    create_table :positions_coins do |t|
      t.references :position, null: false, foreign_key: true, index: false
      t.references :coin, null: false, foreign_key: true
      t.decimal :amount
      t.decimal :price
      t.decimal :min_price
      t.decimal :max_price

      t.timestamps
    end

    add_column :positions_coins, :number, :positions_coins_number, default: '0', null: false
    add_index :positions_coins, %i[position_id number], unique: true
  end

  def down
    drop_table :positions_coins

    safety_assured do
      execute <<-SQL
        DROP TYPE positions_coins_number
      SQL
    end
  end
end
