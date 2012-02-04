# coding: UTF-8
class AuthorsController < ApplicationController

  def index
    # gather the search term for each panel
    @panels = []
    @panels << {q: params[:q].strip} if params[:q]

    nil_panel_added = false
    for panel in @panels
      panel[:author] = Author.find_by_names(panel[:q]).first
      nil_panel_added ||= !panel[:author]
    end
    @panels << {} unless nil_panel_added
  end

  def all
    respond_to do |format|
      format.json {render :json => AuthorName.search(params[:term]).to_json}
      format.html
    end
  end
end
