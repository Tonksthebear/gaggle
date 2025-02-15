module Gaggle
  class ThreadsController < ApplicationController
    def show
      @thread = Gaggle::Thread.find(params[:id])
    end

    def new
      render plain: "Thread new"
    end

    def create
      render plain: "Thread created"
    end

    def edit
      render plain: "Thread edit: #{params[:id]}"
    end

    def update
      render plain: "Thread updated: #{params[:id]}"
    end

    def destroy
      render plain: "Thread destroyed: #{params[:id]}"
    end

    private

    def thread_params
      params.require(:gaggle_thread).permit(:name)
    end
  end
end
