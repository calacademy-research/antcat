class ChangesController < ApplicationController

  def index
    @changes = Change.order('created_at DESC').
      paginate(page: params[:page]).
      all
  end

end
