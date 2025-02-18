class CreateGaggleTables < ActiveRecord::Migration[6.0]
  def change
    create_table :gaggle_gooses do |t|
      t.string :name, null: false
      t.text :prompt
      t.string :process_pid
      t.timestamps
    end

    create_table :gaggle_threads do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :gaggle_messages do |t|
      t.text :content, null: false
      t.references :thread, null: false, foreign_key: { to_table: :gaggle_threads }
      t.references :goose, null: true, foreign_key: { to_table: :gaggle_gooses }
      t.timestamps
    end

    create_table :gaggle_notifications do |t|
      t.references :message, null: true, foreign_key: { to_table: :gaggle_messages }
      t.references :goose, foreign_key: { to_table: :gaggle_gooses }
      t.datetime :read_at
      t.timestamps
    end
  end
end
