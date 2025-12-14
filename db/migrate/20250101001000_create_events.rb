class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.references :agent, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :host, null: false
      t.jsonb :payload, null: false, default: {}
      t.datetime :occurred_at, null: false

      t.timestamps
    end

    add_index :events, :event_type
    add_index :events, :occurred_at
    add_index :events, :host
  end
end
