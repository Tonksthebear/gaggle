class CreateGaggleGooseSessionsAndRemoveProcessPidFromGooses < ActiveRecord::Migration[6.0]
  def change
    create_table :gaggle_sessions do |t|
      t.references :goose, null: false, foreign_key: { to_table: :gaggle_gooses }
      t.text :output
      t.timestamps
    end

    remove_column :gaggle_gooses, :process_pid, :integer
  end
end
