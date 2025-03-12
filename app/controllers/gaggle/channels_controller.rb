module Gaggle
  class ChannelsController < ApplicationController
    before_action :set_channel, except: :index

    permitted_params_for :create do
      param :channel, required: true do
        param :name, type: :string, example: "Channel Name", required: true
        param :goose_ids, type: :array, item_type: :string, example: [ "1", "2" ]
      end
    end

    permitted_params_for :update do
      param :channel, required: true do
        param :name, type: :string, example: "Channel Name"
        param :goose_ids, type: :array, item_type: :string, example: [ "1", "2" ]
      end
    end


    tool_description_for :index, "View all messages in a channel"
    def index; end

    def show
      @notification = Current.goose_user&.notifications&.unread&.for_messageable(@channel)&.first
    end

    def new; end

    def create
      @channel.assign_attributes(resource_params)

      if @channel.save
        respond_to do |format|
          format.html { redirect_to @channel, notice: "Channel was successfully created." }
          format.json { render json: @channel, status: :created, location: @channel }
        end
      else
        respond_to do |format|
          format.html { render :new }
          format.json { render json: @channel.errors, status: :unprocessable_entity }
        end
      end
    end

    def edit; end

    def update
      if @channel.update(resource_params)
        respond_to do |format|
          format.html { redirect_to @channel, notice: "Channel was successfully updated." }
          format.json { render json: @channel, status: :ok, location: @channel }
        end

        Turbo::StreamsChannel.broadcast_update_to "application",
          targets: ".#{dom_id(@channel, :title)}",
          content: @channel.name
      else
        respond_to do |format|
          format.html { render :edit }
          format.json { render json: @channel.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @channel.destroy
      respond_to do |format|
        format.html { redirect_to root_url, notice: "Channel was successfully destroyed." }
        format.json { render json: "#{@channel.name} was successfully destroyed.", status: :ok }
      end
    end

    private

    def set_channels
      @channels = Gaggle::Channel.includes(:gooses)
    end

    def set_channel
      @channel = Gaggle::Channel.includes(messages: :goose).find_by(id: params[:channel_id] || params[:id]) || Gaggle::Channel.new
    end
  end
end
