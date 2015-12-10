# coding: UTF-8
class PublishersController < ApplicationController
  def index
    render json: Publisher.search(params[:term])
  end
end
