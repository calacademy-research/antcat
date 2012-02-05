# coding: UTF-8
class AuthorsController < ApplicationController

  def index
    @panels = []
    @panels = params[:other_terms].inject([]) {|panels, term| panels << {q: term}} if params[:other_terms].present?
    @panels << {q: params[:q].strip} if params[:q].present? if params[:commit] == 'Go'

    all_terms = @panels.map{|panel| panel[:q]}

    blank_panel_added = false
    for panel in @panels
      author = Author.find_by_names(panel[:q]).first
      if @panels.find {|a_panel| a_panel != panel && a_panel[:author] == author}
        panel[:already_open] = true
      else
        panel[:author] = author
      end
      blank_panel_added ||= !panel[:author]
    end
    @panels << {} unless blank_panel_added

    @panels.each {|panel| panel[:other_terms] = all_terms - [panel[:q]]}
  end

  def all
    respond_to do |format|
      format.json {render :json => AuthorName.search(params[:term]).to_json}
      format.html
    end
  end
end
