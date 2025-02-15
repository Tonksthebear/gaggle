module Gaggle
  class ThreadsController < ApplicationController
    def index
      render plain: "Threads index"
    end

    def show
      render plain: "Thread show: #{params[:id]}"
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
  end
end
