class ChangesController < ApplicationController

  def index
    @changes = Change.order('created_at DESC').all
  end

end
