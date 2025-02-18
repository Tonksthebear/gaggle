module Gaggle
  class Thread < ApplicationRecord
    self.table_name = "gaggle_threads"

    has_many :messages, class_name: "Gaggle::Message", dependent: :destroy

    validates :name, presence: true
  end
end
