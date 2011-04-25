class TaxatryController < ApplicationController

  before_filter :search

  def search
    if params['commit'] == 'Clear'
      params['q'] = params['search_type'] = nil
      return
    end

    if params['q'].present?
      params['id'] = nil if params['commit'] == 'Go'
      @search_results = Taxon.find_name params['q'], params['search_type']
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
