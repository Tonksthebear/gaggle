module Gaggle
  class Thread < ApplicationRecord
    self.table_name = "gaggle_threads"

    has_many :messages, class_name: "Gaggle::Message", dependent: :destroy

    validates :name, presence: true

    after_create_commit :broadcast_create
    after_update_commit :broadcast_update
    after_destroy_commit :broadcast_destroy

    def broadcast_create
      broadcast_before_to "gaggle",
      targets: ".new-thread",
      content: ApplicationController.render(
        partial: "gaggle/threads/thread",
        locals: { thread: self }
      )
    end

    def broadcast_update
      broadcast_replace_to "gaggle",
        targets: ".#{dom_id(self, :sidebar)}",
        partial: "gaggle/threads/thread",
        content: ApplicationController.render(
          partial: "gaggle/threads/thread",
          locals: { thread: self }
        )
    end

    def broadcast_destroy
      broadcast_remove_to "gaggle", targets: ".#{dom_id(self, :sidebar)}"
    end
  end
end
