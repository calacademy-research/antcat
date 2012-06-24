# coding: UTF-8
class Catalog::IndexController < CatalogController

  def show
    super

    #@current_path = index_catalog_path

    params[:id] = Family.first.id if params[:id].blank?
    convert_params_to_boolean
    @taxon = Taxon.find params[:id]

    @subfamilies = ::Subfamily.ordered_by_name

    case @taxon

    when Family
      @subfamily = params[:subfamily]
      @tribe = params[:tribe]
      if @subfamily == 'none'
        @genera = Genus.without_subfamily.ordered_by_name
      elsif @tribe == 'none'
        @subfamily = Taxon.find @subfamily
        @taxon = @subfamily
        @tribes = @subfamily.tribes.ordered_by_name
        @genera = @subfamily.genera.without_tribe.ordered_by_name
      end

    when Subfamily
      @subfamily = @taxon
      if params[:hide_tribes]
        @genera = @subfamily.genera.ordered_by_name
      else
        @tribes = @subfamily.tribes.ordered_by_name
      end

    when Tribe
      @tribe = @taxon
      @subfamily = @tribe.subfamily
      if params[:hide_tribes]
        @taxon = @tribe.subfamily
        params[:id] = @taxon.id
        @genera = @subfamily.genera.ordered_by_name
      else
        @tribes = @tribe.siblings.ordered_by_name
        @genera = @tribe.genera.ordered_by_name
      end

    when Genus
      @genus = @taxon
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      if params[:hide_subgenera]
        @specieses = @genus.species_group_descendants
      else
        @subgenera = @genus.subgenera.ordered_by_name
      end
      setup_genus_parent_columns

    when Subgenus
      @subgenus = @taxon
      @genus = @subgenus.genus
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      @subgenera = @genus.subgenera.ordered_by_name
      setup_genus_parent_columns
      @specieses = @subgenus.species_group_descendants

    when Species
      @species = @taxon
      @genus = @species.genus
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      setup_genus_parent_columns
      @specieses = @genus.species_group_descendants

    when Subspecies
      @species = @taxon
      @genus = @species.genus
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      setup_genus_parent_columns
      @specieses = @genus.species_group_descendants

    end

    @page_parameters = {
      id: params[:id], subfamily: @subfamily, tribe: @tribe, genus: @genus, species: @species,
      q: params[:q], search_type: params[:search_type],
      hide_tribes: params[:hide_tribes],
      hide_subgenera: params[:hide_subgenera],
    }

  end

  def convert_param_to_boolean key, default
    case params[key]
    when nil
      params[key] = default
    when 'true'
      params[key] = true
    when 'false'
      params[key] = false
    else
      params[key] = true
    end
  end

  def convert_params_to_boolean
    convert_param_to_boolean :hide_tribes, false
    convert_param_to_boolean :hide_subgenera, true
  end

  def setup_genus_parent_columns
    if params[:hide_tribes]
      @genera = @subfamily == 'none' ? Genus.without_subfamily.ordered_by_name : @subfamily.genera.ordered_by_name
    else
      @genera = @genus.siblings
      @tribe = @genus.tribe ? @genus.tribe : 'none'
      @tribes = @subfamily == 'none' ? nil : @subfamily.tribes.ordered_by_name
    end
  end

end
