class RenameOutputToLogFileGaggleSessions < ActiveRecord::Migration[8.0]
  def change
    rename_column :gaggle_sessions, :output, :log_file
    change_column :gaggle_sessions, :log_file, :string
  end
end
