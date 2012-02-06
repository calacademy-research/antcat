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
    @names = @authors.map{|author| author.names}.flatten.map{|author_name| author_name.name}.uniq
  end

  def format_conjuncted_list items, css_class
    items = items.flatten.uniq.map{|item| "<span class='#{css_class}'>" + item + '</span>'}.sort
    case
    when items.count == 0
      ''
    when items.count == 1
      items.first
    when items.count == 2
      items.first + ' and ' + items.second
    else
      items[0..-2].join(', ') + ' and ' + items.last
    end.html_safe
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

    @all_names_string = format_conjuncted_list @names, 'name'
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
