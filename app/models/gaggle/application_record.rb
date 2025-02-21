module Gaggle
  class ApplicationRecord < ActiveRecord::Base
    include ActionView::RecordIdentifier
    self.abstract_class =true
    establish_connection :gaggle
    connects_to database: { writing: :gaggle, reading: :gaggle }
  end
end
