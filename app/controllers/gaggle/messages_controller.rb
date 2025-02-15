module Gaggle
  class MessagesController < ApplicationController
    def index
      render plain: "Messages index"
    end

    def show
      render plain: "Message show: #{params[:id]}"
    end

    def edit
      render plain: "Message edit: #{params[:id]}"
    end

    def update
      render plain: "Message updated: #{params[:id]}"
    end

    def destroy
      render plain: "Message destroyed: #{params[:id]}"
    end
  end
end
