module Gaggle
  class ChannelsController < ApplicationController
    before_action :set_channel

    def index; end

    def show; end

    def new; end

    def create
      @channel.assign_attributes(channel_params)

      if @channel.save
        redirect_to @channel, notice: "Channel was successfully created."
      else
        render :new
      end
    end

    def edit; end

    def update
      if @channel.update(channel_params)
        redirect_to @channel, notice: "Channel was successfully updated."
        Turbo::StreamsChannel.broadcast_update_to "application",
          targets: ".#{dom_id(@channel, :title)}",
          content: @channel.name
      else
        render :edit
      end
    end

    def destroy
      @channel.destroy
      redirect_to root_url
    end

    private

    def set_channel
      @channel = Gaggle::Channel.includes(messages: :goose).find_by(id: params[:id] || params[:channel_id]) || Gaggle::Channel.new
    end

    def channel_params
      params.require(:channel).permit(:name)
    end
  end
end
