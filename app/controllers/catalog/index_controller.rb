# coding: UTF-8
class Catalog::IndexController < CatalogController

  def show
    super

    #@current_path = index_catalog_path

    @subfamilies = ::Subfamily.ordered_by_name

    params[:id] = Family.first.id if params[:id].blank?

    @taxon = Taxon.find params[:id]

    case @taxon

    when Family
      @subfamily = params[:subfamily]
      @tribe = params[:tribe]
      if @subfamily == 'none'
        @genera = Genus.without_subfamily
        @genus = nil
      elsif @tribe == 'none'
        @subfamily = Taxon.find @subfamily
        @taxon = @subfamily
        @tribes = @subfamily.tribes
        @genera = @subfamily.genera.without_tribe
        @genus = nil
      else
        @tribe = nil
        @tribes = nil
        @genus = nil
        @genera = nil
      end
      @specieses = nil
      @species = nil

    when Subfamily
      @subfamily = @taxon

      if params[:hide_tribes]
        @genera = @subfamily.genera
      else
        @genera = nil
        @tribe = nil
        @tribes = @subfamily.tribes
      end

      @genus = nil
      @species = nil
      @specieses = nil

    when Tribe
      @tribe = @taxon

      if params[:hide_tribes]
        @subfamily = @tribe.subfamily
        @genera = nil
      else
        @subfamily = @tribe.subfamily
        @tribes = @tribe.siblings
        @genera = @tribe.genera
      end

      @genus = nil
      @species = nil
      @specieses = nil

    when Genus
      @genus = @taxon
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'

      if params[:hide_tribes]
        @genera = @subfamily == 'none' ? Genus.without_subfamily : @subfamily.genera
      else
        @genera = @genus.siblings
        @tribe = @genus.tribe ? @genus.tribe : 'none'
        @tribes = @subfamily == 'none' ? nil : @subfamily.tribes
      end

      @species = nil
      @specieses = @genus.species

    when Species
      @species = @taxon
      @genus = @species.genus
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'

      if params[:hide_tribes]
        @genera = @subfamily == 'none' ? Genus.without_subfamily : @subfamily.genera
      else
        @genera = @genus.siblings
        @tribe = @genus.tribe ? @genus.tribe : 'none'
        @tribes = @subfamily == 'none' ? nil : @subfamily.tribes
      end

      @specieses = @species.siblings
    end

    @page_parameters = {
      id: params[:id], subfamily: @subfamily, tribe: @tribe, genus: @genus, species: @species,
      q: params[:q], search_type: params[:search_type],
      hide_tribes: params[:hide_tribes]
    }

  end

end
