module Gaggle
  class Channels::MessagesController < Gaggle::ChannelsController
    skip_before_action :verify_authenticity_token

    permitted_params_for :create do
      param :message, required: true do
        param :content, type: :string, example: "Message Content", required: true
      end
    end

    tool_description_for :create, "Send a message to the channel"
    def create
      @message = @channel.messages.new(resource_params)
      if @message.save
        respond_to do |format|
          format.html { redirect_to @channel, notice: "Message sent." }
          format.json { render json: @message, status: :created, location: @message }
        end
      else
        respond_to do |format|
          format.html { render :new, notice: "Message was not sent." }
          format.json { render json: @message.errors, status: :unprocessable_entity }
        end
      end
    end
  end
end
