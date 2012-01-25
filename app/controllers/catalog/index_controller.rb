# coding: UTF-8
class Catalog::IndexController < CatalogController

  def show
    super

    #@current_path = index_catalog_path

    params[:id] = Family.first.id if params[:id].blank?
    @taxon = Taxon.find params[:id]

    @subfamilies = ::Subfamily.ordered_by_name

    case @taxon

    when Family
      @subfamily = params[:subfamily]
      @tribe = params[:tribe]
      if @subfamily == 'none'
        @genera = Genus.without_subfamily
      elsif @tribe == 'none'
        @subfamily = Taxon.find @subfamily
        @taxon = @subfamily
        @tribes = @subfamily.tribes
        @genera = @subfamily.genera.without_tribe
      end

    when Subfamily
      @subfamily = @taxon
      if params[:hide_tribes]
        @genera = @subfamily.genera
      else
        @tribes = @subfamily.tribes
      end

    when Tribe
      @tribe = @taxon
      @subfamily = @tribe.subfamily
      if params[:hide_tribes]
        @taxon = @tribe.subfamily
        params[:id] = @taxon.id
        @genera = @subfamily.genera
      else
        @tribes = @tribe.siblings
        @genera = @tribe.genera
      end

    when Genus
      @genus = @taxon
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      setup_genus_parent_columns
      @specieses = @genus.species

    when Species
      @species = @taxon
      @genus = @species.genus
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      setup_genus_parent_columns
      @specieses = @species.siblings
    end

    @page_parameters = {
      id: params[:id], subfamily: @subfamily, tribe: @tribe, genus: @genus, species: @species,
      q: params[:q], search_type: params[:search_type],
      hide_tribes: params[:hide_tribes]
    }

  end

  def setup_genus_parent_columns
    if params[:hide_tribes]
      @genera = @subfamily == 'none' ? Genus.without_subfamily : @subfamily.genera
    else
      @genera = @genus.siblings
      @tribe = @genus.tribe ? @genus.tribe : 'none'
      @tribes = @subfamily == 'none' ? nil : @subfamily.tribes
    end
  end

end
