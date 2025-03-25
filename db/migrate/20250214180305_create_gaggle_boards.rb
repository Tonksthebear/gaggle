class CreateGaggleBoards < ActiveRecord::Migration[6.1]
  def change
    create_table :gaggle_boards do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
