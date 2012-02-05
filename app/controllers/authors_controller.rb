# coding: UTF-8
class AuthorsController < ApplicationController

  def create_panels
    # default to an empty collection of terms
    params[:terms] ||= []

    # if closing a panel, remove its term
    params[:terms].delete params[:term] unless params[:commit]

    # make a panel for each search term and find its author
    @panels = params[:terms].map do |term|
      panel = {term: term.strip, author: Author.find_by_names(term).first}
    end
    @panels_with_authors = @panels.select{|panel| panel[:author]}
    @authors = @panels_with_authors.map{|panel| panel[:author]}
  end

  def index
    create_panels

    # recognize duplicate panels
    for panel in @panels
      panel[:already_open] = panel[:author] && @panels.find {|a_panel| a_panel != panel && a_panel[:author] == panel[:author]}
      panel[:author] = nil if panel[:already_open]
    end

    # add a blank panel if necessary
    @panels << {term: ''} unless @panels.find {|panel| !panel[:author]}

    #@all_authors = []
    #blank_panel_added = false
    #for panel in @panels
      #if @panels.find {|a_panel| a_panel != panel && a_panel[:author] == panel[:author]}
        #panel[:already_open] = true
      #end
      #blank_panel_added ||= !panel[:author]
    #end
    #@panels << {} unless blank_panel_added

    #all_names = @panels.select{|panel| panel[:author]}.collect{|panel| panel[:author].names}
    #all_names = all_names.flatten.uniq.map{|name| '"' + name.name + '"'}.sort
    #@all_names_string = case
    #when all_names.count == 0
    #when all_names.count == 1
      #all_names.first
    #when all_names.count == 2
      #all_names.first + ' and ' + all_names.second
    #else
      #all_names[0..-2].join(', ') + ' and ' + all_names.last
    #end
  end

  def merge
    create_panels
    term = @panels_with_authors.first[:term]
    Author.merge @authors
    params[:terms] = [term]
    index
    render :index
  end

  def all
    respond_to do |format|
      format.json {render :json => AuthorName.search(params[:term]).to_json}
      format.html
    end
  end
end
