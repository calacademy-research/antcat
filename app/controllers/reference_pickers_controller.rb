# coding: UTF-8
class ReferencePickersController < ApplicationController

  def show
    params[:search_selector] ||= 'Search for author(s)'

    if params[:id].present?
      reference = Reference.find params[:id]
      DefaultReference.set session, reference
    end

    if params[:q].present?
      params[:q].strip!
      params[:is_author_search] = params[:search_selector] == 'Search for author(s)'
      references = Reference.do_search params
    end

    render partial: "reference_#{picker_type}s/show", locals: {references: references, reference: reference}
  end

end
