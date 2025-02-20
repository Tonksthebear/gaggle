module Gaggle
  class Channel < ApplicationRecord
    self.table_name = "gaggle_channels"

    has_many :messages, class_name: "Gaggle::Message", as: :messageable, dependent: :destroy
    has_and_belongs_to_many :geese
    has_many :notifications, class_name: "Gaggle::Notification", dependent: :destroy, as: :messageable

    validates :name, presence: true

    after_create_commit :broadcast_create
    after_update_commit :broadcast_update
    after_destroy_commit :broadcast_destroy

    def broadcast_create
      broadcast_before_to "gaggle",
      targets: ".new-channel",
      content: ApplicationController.render(
        partial: "gaggle/channels/channel",
        locals: { channel: self }
      )
    end

    def broadcast_update
      broadcast_replace_to "gaggle",
        targets: ".#{dom_id(self, :sidebar)}",
        partial: "gaggle/channels/channel",
        content: ApplicationController.render(
          partial: "gaggle/channels/channel",
          locals: { channel: self }
        )
    end

    def broadcast_destroy
      broadcast_remove_to "gaggle", targets: ".#{dom_id(self, :sidebar)}"
    end
  end
end
