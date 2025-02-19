class ReplaceThreadWithMessageableMessage < ActiveRecord::Migration[8.0]
  def change
    add_reference :gaggle_messages, :messageable, polymorphic: true, null: true
  end
end
