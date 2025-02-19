class ForMessageableMessage < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      Gaggle::Message.find_each do |message|
        message.update_columns(messageable_type: 'Gaggle::Thread', messageable_id: message.thread_id)
      end
    end

    remove_reference :gaggle_messages, :thread
    change_column_null :gaggle_messages, :messageable_id, false
    change_column_null :gaggle_messages, :messageable_type, false
  end
end
