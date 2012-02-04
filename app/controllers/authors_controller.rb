# coding: UTF-8
class AuthorsController < ApplicationController

  def index
    # create the other panels
    @panels = []
    @panels = params[:other_terms].inject([]) {|panels, term| panels << {q: term}} if params[:other_terms].present?
    @panels << {q: params[:q].strip} if params[:q].present?

    # gather the search terms
    all_terms = @panels.map{|panel| panel[:q]}

    # find the author for each panel
    blank_panel_added = false
    for panel in @panels
      panel[:author] = Author.find_by_names(panel[:q]).first
      blank_panel_added ||= !panel[:author]
    end

    # add a blank panel unless there was already a panel with a failed search
    @panels << {} unless blank_panel_added

    # save the other panels' terms in each panel
    for panel in @panels
      panel[:other_terms] = all_terms - [panel[:q]]
    end

  end

  def all
    respond_to do |format|
      format.json {render :json => AuthorName.search(params[:term]).to_json}
      format.html
    end
  end
end
