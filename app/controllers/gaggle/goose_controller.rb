module Gaggle
  class GooseController < ApplicationController
    def index
      render plain: "Goose index"
    end

    def show
      render plain: "Goose show: #{params[:id]}"
    end

    def new
      render plain: "Goose new"
    end

    def create
      render plain: "Goose created"
    end

    def edit
      render plain: "Goose edit: #{params[:id]}"
    end

    def update
      render plain: "Goose updated: #{params[:id]}"
    end

    def destroy
      render plain: "Goose destroyed: #{params[:id]}"
    end
  end
end
