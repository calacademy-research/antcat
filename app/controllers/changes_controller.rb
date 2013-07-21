class ChangesController < ApplicationController

  def index
    @changes = Change.
      joins(:paper_trail_version).
      where('versions.event' => 'create').
      order('created_at DESC').
      paginate(page: params[:page])
  end

end
