# coding: UTF-8
class ReferencePickersController < ApplicationController

  def create
    if params[:id].present?
      @references = Reference.perform_search id: params[:id]
    else
      params[:search_selector] ||= 'Search for'
      if ['clear'].include? params[:commit]
        params[:q] = ''
      end
      params[:q].strip! if params[:q]
      #params[:is_author_search] = params[:search_selector] == 'Search for author(s)'

      @references = Reference.do_search params
    end

    render partial: 'create'
    raise if @references.size == Reference.count
  end

end
