class TaxatryController < ApplicationController

  caches_action :show, :layout => false

  def show
    search
  end

  def search
    if params['commit'] == 'Clear'
      @search_params = {}
      params['q'] = params['search_type'] = nil
      return
    end

    @search_params = {'search_type' => params['search_type'], 'q' => params['q']}

    if @search_params['q'].present?
      params['id'] = nil if params[:is_search_form].present?
      @search_results = Taxon.find_name @search_params['q'], @search_params['search_type']
      unless @search_results.present?
        @search_results_message = "No results found"
      else
        @search_results = @search_results.map do |search_result|
          {:name => search_result.full_name, :id => search_result.id}
        end.sort_by {|element| element[:name]}
        params['id'] = @search_results.first[:id] if params['id'].blank?
      end
    end
  end

end
