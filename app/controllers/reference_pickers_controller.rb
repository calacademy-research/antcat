# coding: UTF-8
class ReferencePickersController < ApplicationController

  def show
    params[:search_selector] ||= 'Search for author(s)'

    if params[:id].present?
      @references = Reference.perform_search id: params[:id]
      @selected_reference = @references.first
    end

    if params[:q].present?
      params[:q].strip!
      params[:is_author_search] = params[:search_selector] == 'Search for author(s)'
      @references = Reference.do_search params
    end

    render partial: 'show', locals: {selected_reference: @selected_reference, references: @references}
  end

end
