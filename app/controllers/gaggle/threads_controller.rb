module Gaggle
  class ThreadsController < ApplicationController
    before_action :set_thread

    def show; end

    def new; end

    def create
      @thread.assign_attributes(thread_params)

      if @thread.save
        redirect_to @thread, notice: "Thread was successfully created."
      else
        render :new
      end
    end

    def edit; end

    def update
      if @thread.update(thread_params)
        redirect_to @thread, notice: "Thread was successfully updated."
        Turbo::StreamsChannel.broadcast_update_to "application",
          targets: ".#{dom_id(@thread, :title)}",
          content: @thread.name
      else
        render :edit
      end
    end

    def destroy
      @thread.destroy
      redirect_to root_url
    end

    private

    def set_thread
      @thread = Gaggle::Thread.find_by(id: params[:id]) || Gaggle::Thread.new
    end

    def thread_params
      params.require(:thread).permit(:name)
    end
  end
end
