class JournalsController < ApplicationController
  def index
    render :json => Journal.search(params[:term]).to_json
  end
end
