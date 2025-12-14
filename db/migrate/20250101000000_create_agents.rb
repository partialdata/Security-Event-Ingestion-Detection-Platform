class CreateAgents < ActiveRecord::Migration[7.1]
  def change
    create_table :agents do |t|
      t.string :name, null: false
      t.string :api_token_digest, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :agents, :api_token_digest, unique: true
  end
end
