# frozen_string_literal: true

class CreateCoins < ActiveRecord::Migration[7.0]
  def change
    create_table :coins do |t|
      t.string :address, null: false, index: { unique: true }
      t.string :symbol, null: false
      t.integer :decimals, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
