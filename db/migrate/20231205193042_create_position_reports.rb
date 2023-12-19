# frozen_string_literal: true

class CreatePositionReports < ActiveRecord::Migration[7.0]
  def up
    safety_assured do
      execute <<-SQL.squish
        CREATE TYPE position_report_status AS ENUM (
          'fees_info_fetching',
          'history_analyzing',
          'completed',
          'failed'
        )
      SQL
    end

    create_table :position_reports do |t|
      t.references :position, null: false, foreign_key: true
      t.integer :message_id
      t.string :error_message

      t.timestamps
    end

    add_column :position_reports, :status, :position_report_status, default: 'fees_info_fetching', null: false
  end

  def down
    drop_table :position_reports

    safety_assured do
      execute <<-SQL
        DROP TYPE position_report_status
      SQL
    end
  end
end