module Gaggle
  class Thread < ApplicationRecord
    self.table_name = "gaggle_threads"

    has_many :messages, class_name: "Gaggle::Message", foreign_key: "gaggle_thread_id", dependent: :destroy

    validates :name, presence: true
  end
end
