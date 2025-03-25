class CreateGaggleColumns < ActiveRecord::Migration[6.1]
  def change
    create_table :gaggle_columns do |t|
      t.string :name, null: false
      t.references :board, null: false, foreign_key: { to_table: :gaggle_boards }

      t.timestamps
    end
  end
end
