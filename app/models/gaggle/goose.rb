module Gaggle
  class Goose < ApplicationRecord
    self.table_name = "gaggle_gooses"

    # process_pid: string - stores the process PID of the actual Goose CLI
    has_many :messages, class_name: "Gaggle::Message", foreign_key: "gaggle_goose_id"

    validates :name, presence: true
  end
end
