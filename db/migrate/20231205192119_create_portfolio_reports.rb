# frozen_string_literal: true

class CreatePortfolioReports < ActiveRecord::Migration[7.0]
  def up
    safety_assured do
      execute <<-SQL.squish
        CREATE TYPE portfolio_report_status AS ENUM (
          'initialized',
          'positions_fetched',
          'prices_fetched',
          'events_fetched',
          'completed',
          'failed'
        )
      SQL
    end

    create_table :portfolio_reports do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :initial_message_id
      t.integer :summary_message_id
      t.jsonb :prices, null: false, default: {}
      t.string :error_message

      t.timestamps
    end

    add_column :portfolio_reports, :status, :portfolio_report_status, default: 'initialized', null: false
  end

  def down
    drop_table :portfolio_reports

    safety_assured do
      execute <<-SQL
        DROP TYPE portfolio_report_status
      SQL
    end
  end
end
