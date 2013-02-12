# coding: UTF-8
class ReferencePopupsController < ApplicationController

  def show
    params[:search_selector] ||= 'Search for author(s)'

    reference = Reference.find params[:id] if params[:id].present?

    if params[:q].present?
      params[:q].strip!
      params[:is_author_search] = params[:search_selector] == 'Search for author(s)'
      references = Reference.do_search params
    end

    render partial: 'show', locals: {references: references, reference: reference}
  end

end
