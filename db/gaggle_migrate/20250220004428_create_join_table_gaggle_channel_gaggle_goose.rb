class CreateJoinTableGaggleChannelGaggleGoose < ActiveRecord::Migration[6.0]
  def change
    create_join_table :channels, :gooses, table_name: :gaggle_channels_gooses do |t|
      t.index [ :channel_id, :goose_id ]
      t.index [ :goose_id, :channel_id ]
    end
  end
end
