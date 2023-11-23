# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :address, null: false, index: { unique: true }
      t.string :telegram_chat_id

      t.timestamps
    end
  end
end
