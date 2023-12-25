# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.integer :telegram_chat_id, index: true
      t.integer :menu_message_id
      t.string :locale, null: false, default: :en

      t.timestamps
    end
  end
end
