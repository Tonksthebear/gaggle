module Gaggle
  class ApplicationController < ActionController::Base
    include ActionView::RecordIdentifier
    before_action :set_channels
    before_action :set_geese
    before_action :set_goose_user
    skip_before_action :verify_authenticity_token, if: :mcp_invocation?

    private

    def set_channels
      @channels = Gaggle::Channel.all
    end

    def set_geese
      @geese = Gaggle::Goose.all
    end

    def set_goose_user
      @goose_user = Goose.find_by(id: params[:goose_user_id])
    end
  end
end
