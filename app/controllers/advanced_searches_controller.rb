# coding: UTF-8
class AdvancedSearchesController < ApplicationController
  include Formatters::Formatter
  def show
    if params[:rank].present?
      @taxa = Taxon.advanced_search author_name: params[:author_name], rank: params[:rank], year: params[:year], valid_only: params[:valid_only]
      @taxa_count = @taxa.count
      set_search_results_message
    end
  end

  def set_search_results_message
    if @taxa.present?
      @search_results_message = "#{pluralize_with_delimiters(@taxa_count, 'result')} found"
    else
      if no_matching_authors? params[:author_name]
        @search_results_message = "No results found for author '#{params[:author_name]}'. If you're choosing an author, make sure you pick the name from the dropdown list."
      else
        @search_results_message = "No results found."
      end
    end
  end

  def no_matching_authors? name
    AuthorName.find_by_name(params[:author_name]).nil?
  end

end
