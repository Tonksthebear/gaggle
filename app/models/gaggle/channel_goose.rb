module Gaggle
  class ChannelGoose < ApplicationRecord
    self.table_name = "gaggle_channels_gooses"

    belongs_to :channel, class_name: "Gaggle::Channel"
    belongs_to :goose, class_name: "Gaggle::Goose"

    validates :channel_id, uniqueness: { scope: :goose_id }, presence: true
    validates :goose_id, uniqueness: { scope: :channel_id }, presence: true
  end
end
