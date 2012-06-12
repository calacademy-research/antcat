# coding: UTF-8
class CatalogController < ApplicationController

  def create
    tribe = Tribe.find params[:genus][:tribe]
    genus = Genus.new(
      name: params[:genus][:name],
      status: 'valid',
      tribe: tribe)
    genus.save

    json = {
      isNew: true,
      content: render_to_string(partial: 'catalog/index/taxon_form', locals: {genus: genus, tribe: tribe}),
      success: genus.errors.empty?
    }.to_json

    render json: json, content_type: 'text/html'
  end

  def show
    if params['commit'] == 'Clear'
      @search_params = {}
      params['q'] = params['search_type'] = nil
      return
    end

    params['q'].strip! if params['q']

    @search_params = {'search_type' => params['search_type'], 'q' => params['q']}

    if @search_params['q'].present?
      params['id'] = nil if params[:is_search_form].present?
      @search_results = Taxon.find_name @search_params['q'], @search_params['search_type']
      unless @search_results.present?
        @search_results_message = "No results found"
      else
        @search_results = @search_results.map do |search_result|
          {name: search_result.label, id: search_result.id}
        end
        params['id'] = @search_results.first[:id] if params['id'].blank?
      end
    end
  end

end
