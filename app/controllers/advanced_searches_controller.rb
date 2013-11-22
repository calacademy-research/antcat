# coding: UTF-8
class AdvancedSearchesController < ApplicationController
  include Formatters::Formatter
  include Formatters::AdvancedSearchTextFormatter

  def show
    if params[:rank].present?
      get_taxa
      set_search_results_message
    end
    respond_to do |format|
      format.json {send_author_name_picklist}
      format.html {send_html}
      format.txt  {send_text}
    end
  end

  def send_author_name_picklist
    render json: AuthorName.search(params[:term]).to_json
  end

  def send_html
    @taxa = @taxa.paginate page: params[:page] if @taxa
  end

  def send_text
    text = Exporters::AdvancedSearchExporter.new.export @taxa
    send_data text, filename: @filename, type: 'text/plain'
  end

  def set_search_results_message
    if @taxa.present?
      @search_results_message = "#{pluralize_with_delimiters(@taxa_count, 'result')} found"
    else
      if params[:author_name].present? && no_matching_authors?(params[:author_name])
        @search_results_message = "No results found for author '#{params[:author_name]}'. If you're choosing an author, make sure you pick the name from the dropdown list."
      else
        @search_results_message = "No results found."
      end
    end
  end

  def no_matching_authors? name
    AuthorName.find_by_name(name).nil?
  end

  def get_taxa
    @taxa = Taxon.advanced_search author_name: params[:author_name],
                                  rank: params[:rank],
                                  year: params[:year],
                                  locality: params[:locality],
                                  valid_only: params[:valid_only],
                                  verbatim_type_locality: params[:verbatim_type_locality],
                                  biogeographic_region: params[:biogeographic_region]
    @taxa_count = @taxa.count
    @filename = "#{params[:author_name]}-#{params[:rank]}-#{params[:year]}-#{params[:locality]}-#{params[:valid_only]}".parameterize + '.txt'
  end
end
