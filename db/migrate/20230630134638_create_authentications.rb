# frozen_string_literal: true

class CreateAuthentications < ActiveRecord::Migration[7.0]
  def change
    create_table :authentications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address, null: false
      t.datetime :last_usage_at
      t.string :token, null: false, index: true

      t.timestamps
    end
  end
end
