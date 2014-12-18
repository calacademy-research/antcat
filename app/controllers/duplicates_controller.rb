# Controller to handle the duplicates cases -
# cases where a species move from one genus to anohter - starting off in
# genus A, moving to genus B, and then back to A, while retaining the same
# species epithet.

class DuplicatesController < TaxaController
  before_filter :authenticate_editor, :get_params, :create_mother



  # Takes requires parent_id (target parent)and previous_combination_id
  # returns all matching taxa that could conflict with this naming.
  def show
    if @rank_to_create != Rank['species']
      render :nothing => true, status: :no_content
      return
    end

    new_parent = Taxon.find(@parent_id)
    options = Taxon.find_epithet_in_genus @previous_combination.name.epithet, new_parent
    if options.nil?
      render :nothing => true, status: :no_content
      return
    end
    options.each do |option|
      # puts "name: " + option.name.name + " " +
      #          "author: " + option.protonym.authorship_string  +
      #          " id: " + option[:id].to_s
      # puts "protonym id : " + option.protonym[:id].to_s
      option[:authorship_string] = option.protonym.authorship_string
    end
    render json: options.to_json, status: :ok
  end

  # Sort of a misnomer; arrive here to create the duplicate (from taxa.coffee)case because we're re-writing the action
  # for the form submit which USED to go to taxa_controller.create.

  def create
    setup_taxon
    set_paths :create
    save_original_taxon
  end

  def setup_taxon
    parent = Taxon.find(@parent_id)
    if @previous_combination
      Taxon.inherit_attributes_for_new_combination(@original_combination, @previous_combination, parent)
    end

  end

  def save_original_taxon
    @mother.save_taxon @original_combination, @taxon_params, @previous_combination
    if @previous_combination && @previous_combination.is_a?(Species) && @previous_combination.children.any?
      create_new_usages_for_subspecies
    end
    redirect_to catalog_path @taxon
  rescue ActiveRecord::RecordInvalid, Taxon::TaxonExists
    render :edit and return
  end

  def get_params
    @original_species_id = params[:original_species_id]
    if !@original_species_id.nil?
      @original_combination = Taxon.find(@original_species_id)
    end
    super
  end
end





