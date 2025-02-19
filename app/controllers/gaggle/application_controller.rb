module Gaggle
  class ApplicationController < ActionController::Base
    include ActionView::RecordIdentifier
    before_action :set_channels
    before_action :set_geese

    private

    def set_channels
      @channels = Gaggle::Channel.all
    end

    def set_geese
      @geese = Gaggle::Goose.all
    end
  end
end
