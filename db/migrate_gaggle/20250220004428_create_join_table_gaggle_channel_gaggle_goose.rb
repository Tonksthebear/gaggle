class CreateJoinTableGaggleChannelGaggleGoose < ActiveRecord::Migration[8.0]
  def change
    create_join_table :gaggle_channels, :gaggle_gooses do |t|
      t.index [ :gaggle_channel_id, :gaggle_goose_id ]
      t.index [ :gaggle_goose_id, :gaggle_channel_id ]
    end
  end
end
