module Gaggle
  class Goose < ApplicationRecord
  has_many :sessions, class_name: "Gaggle::Session"
    self.table_name = "gaggle_gooses"

    has_many :messages
    has_many :sessions

    validates :name, presence: true
  end
end
