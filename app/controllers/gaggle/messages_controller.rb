module Gaggle
  class MessagesController < ApplicationController
    def destroy
      render plain: "Message destroyed: #{params[:id]}"
    end
  end
end
