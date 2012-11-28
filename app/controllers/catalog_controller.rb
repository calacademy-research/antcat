# coding: UTF-8
class CatalogController < ApplicationController
  before_filter :get_parameters

  def show
    @parameters[:id] = Family.first.id if @parameters[:id].blank?
    do_search
    setup_taxon_and_index
  end

  def search
    if params[:commit] == 'Clear'
      clear_search
    else
      do_search
      set_id_parameter @search_results.first[:id] if @search_results.present?
    end
    setup_taxon_and_index
    render :show
  end

  def show_tribes
    session[:show_tribes] = true
    redirect_to_id
  end

  def hide_tribes
    session[:show_tribes] = false
    taxon = Taxon.find @parameters[:id]
    set_id_parameter taxon.subfamily.id if taxon.kind_of? Tribe
    redirect_to_id
  end

  def show_unavailable_subfamilies
    session[:show_unavailable_subfamilies] = true
    redirect_to_id
  end

  def hide_unavailable_subfamilies
    session[:show_unavailable_subfamilies] = false
    taxon = Family.first
    redirect_to_id
  end

  def show_subgenera
    session[:show_subgenera] = true
    redirect_to_id
  end

  def hide_subgenera
    session[:show_subgenera] = false
    taxon = Taxon.find @parameters[:id]
    set_id_parameter taxon.genus.id if taxon.kind_of? Subgenus
    redirect_to_id
  end

  def redirect_to_id
    id = @parameters.delete :id
    id_string = "/#{id}"
    parameters_string = @parameters.empty? ? '' : "?#{@parameters.to_query}"
    redirect_to "/catalog#{id_string}#{parameters_string}"
  end

  ##########################
  def setup_taxon_and_index
    @taxon = Taxon.find_by_id(@parameters[:id]) || Family.first

    if session[:show_unavailable_subfamilies]
      @subfamilies = ::Subfamily.ordered_by_name
    else
      @subfamilies = ::Subfamily.ordered_by_name.where "status != 'unavailable'"
    end

    case @taxon

    when Family
      if @parameters[:child] == 'none'
        @subfamily = 'none'
        @genera = Genus.without_subfamily.ordered_by_name
      end

    when Subfamily
      @subfamily = @taxon

      if session[:show_tribes]
        @tribes = @subfamily.tribes.ordered_by_name
        if @parameters[:child] == 'none'
          @tribe = 'none'
          @genera = @subfamily.genera.without_tribe.ordered_by_name
        end
      else
        @genera = @subfamily.genera.ordered_by_name
      end

    when Tribe
      @tribe = @taxon
      @subfamily = @tribe.subfamily

      session[:show_tribes] = true
      @tribes = @tribe.siblings.ordered_by_name
      @genera = @tribe.genera.ordered_by_name

    when Genus
      @genus = @taxon
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      setup_genus_parent_columns
      unless session[:show_subgenera]
        @specieses = @genus.species_group_descendants.ordered_by_name
      else
        @subgenera = @genus.subgenera.ordered_by_name.ordered_by_name
      end

    when Subgenus
      @subgenus = @taxon
      @genus = @subgenus.genus
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      session[:show_subgenera] = true
      @subgenera = @genus.subgenera.ordered_by_name
      setup_genus_parent_columns
      @specieses = @subgenus.species_group_descendants.ordered_by_name

    when Species
      @species = @taxon
      @genus = @species.genus
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      setup_genus_parent_columns
      @specieses = @genus.species_group_descendants.ordered_by_name

    when Subspecies
      @species = @taxon
      @genus = @species.genus
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      setup_genus_parent_columns
      @specieses = @genus.species_group_descendants.ordered_by_name

    end
  end

  def setup_genus_parent_columns
    if session[:show_tribes]
      @genera = @genus.siblings.ordered_by_name
      @tribe = @genus.tribe ? @genus.tribe : 'none'
      @tribes = @subfamily == 'none' ? nil : @subfamily.tribes.ordered_by_name
    else
      @genera = @subfamily == 'none' ? Genus.without_subfamily.ordered_by_name : @subfamily.genera.ordered_by_name
    end
  end

  ##########################
  def do_search
    return unless @parameters[:q].present?
    search_selector_value = translate_search_selector_value_to_english @parameters[:st]
    @search_results = Taxon.find_name @parameters[:q], search_selector_value
    if @search_results.blank?
      @search_results_message = "No results found for name #{search_selector_value} '#{@parameters[:q]}'"
    else
      @search_results = @search_results.map do |search_result|
        {name: search_result.name.name_html, id: search_result.id}
      end
    end
  end

  def clear_search
    @parameters.delete :q
    @parameters.delete :st
  end

  def translate_search_selector_value_to_english value
    {'m' => 'matching', 'bw' => 'beginning with', 'c' => 'containing'}[value]
  end

  ##########################
  def create
    tribe = Tribe.find params[:genus][:tribe]
    genus = Genus.new(
      name: params[:genus][:name],
      status: 'valid',
      tribe: tribe)
    genus.save

    json = {
      isNew: true,
      content: render_to_string(partial: 'catalog/taxon_form', locals: {genus: genus, tribe: tribe}),
      success: genus.errors.empty?
    }.to_json

    render json: json, content_type: 'text/html'
  end

  ##########################
  def reverse_synonymy
    taxon = Taxon.find @parameters[:id]
    if taxon.synonym?
      new_junior = taxon.senior_synonyms.first
      new_senior = taxon
    else
      new_senior = taxon.junior_synonyms.first
      new_junior = taxon
    end
    new_junior.become_junior_synonym_of new_senior
    ReverseSynonymyEdit.create! new_junior: new_junior, new_senior: new_senior, user: current_user
    redirect_to_id
  end

  ##########################
  def get_parameters
    @parameters = HashWithIndifferentAccess.new
    @parameters[:id] = params[:id] if params[:id].present?
    @parameters[:child] = params[:child] if params[:child].present?
    @parameters[:q] = params[:q].strip if params[:q].present?
    @parameters[:st] = params[:st] if params[:st].present?
    handle_edit_mode
  end

  def handle_edit_mode
    mode = params[:mode]
    return unless mode.present? 
    session[:mode] = mode
    params.delete :mode
  end

  def set_id_parameter id, child = nil
    @parameters[:id] = id
    if child
      @parameters[:child] = child
    else
      @parameters.delete :child
    end
  end

end
