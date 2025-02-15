class CreateGaggleTables < ActiveRecord::Migration[6.0]
  def change
    create_table :gaggle_gooses do |t|
      t.string :name, null: false
      t.text :prompt
      t.timestamps
    end

    create_table :gaggle_threads do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :gaggle_messages do |t|
      t.text :content, null: false
      t.references :gaggle_thread, null: false, foreign_key: { to_table: :gaggle_threads }
      t.references :gaggle_goose, foreign_key: { to_table: :gaggle_gooses }
      t.timestamps
    end

    create_table :gaggle_notifications do |t|
      t.references :gaggle_message, null: false, foreign_key: { to_table: :gaggle_messages }
      t.references :gaggle_goose, foreign_key: { to_table: :gaggle_gooses }
      t.datetime :read_at
      t.timestamps
    end
  end
end
