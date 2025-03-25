class CreateGaggleTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :gaggle_tasks do |t|
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false
      t.references :assigned_goose, foreign_key: { to_table: :gaggle_gooses }

      t.timestamps
    end
  end
end
