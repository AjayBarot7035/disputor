class CreateWebhookEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_events do |t|
      t.string :event_id, null: false
      t.string :event_type, null: false
      t.jsonb :payload, default: {}
      t.string :dispute_external_id
      t.boolean :processed, default: false, null: false
      t.datetime :processed_at

      t.timestamps
    end

    add_index :webhook_events, :event_id, unique: true
    add_index :webhook_events, :dispute_external_id
    add_index :webhook_events, :processed
  end
end

