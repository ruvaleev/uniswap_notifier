# frozen_string_literal: true

class CreateCurrencies < ActiveRecord::Migration[7.0]
  def change
    create_table :currencies do |t|
      t.string :code, null: false, index: { unique: true }
      t.decimal :usd_price

      t.timestamps
    end
  end
end
