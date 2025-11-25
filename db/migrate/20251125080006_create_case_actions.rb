class CreateCaseActions < ActiveRecord::Migration[8.1]
  def change
    create_table :case_actions do |t|
      t.references :dispute, null: false, foreign_key: true
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.text :note
      t.jsonb :details, default: {}

      t.timestamps
    end
  end
end

