class CreateAlerts < ActiveRecord::Migration[7.1]
  def change
    create_table :alerts do |t|
      t.references :event, null: false, foreign_key: true
      t.references :agent, null: false, foreign_key: true
      t.string :severity, null: false
      t.string :reason, null: false
      t.string :status, null: false, default: "open"
      t.string :dedup_key, null: false

      t.timestamps
    end

    add_index :alerts, :dedup_key
    add_index :alerts, :status
    add_index :alerts, :severity
  end
end
