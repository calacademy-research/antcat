# coding: UTF-8
class Catalog::IndexController < CatalogController

  def show
    #super

    #@current_path = index_catalog_path

    # selected taxon (on top)
    if params[:id].present?
      @taxon = Taxon.find params[:id]
    else
      @taxon = Family.first
    end

    # subfamily column
    @subfamilies = ::Subfamily.ordered_by_name
    @subfamily = params[:subfamily]
    @subfamily = Taxon.find @subfamily if @subfamily && @subfamily != 'none'

    # tribes column
    case @subfamily
    when nil
      @tribes = nil
    when 'none'
      @tribes = nil
    else
      @tribes = @subfamily.tribes
    end
    @tribe = params[:tribe]
    @tribe = Taxon.find @tribe if @tribe && @tribe != 'none'

    # genera column
    case @tribe
    when nil
      if @subfamily == 'none'
        @genera = Genus.without_subfamily
      else
        @genera = nil
      end
    when 'none'
      @genera = @subfamily.genera.without_tribe
    else
      @genera = @tribe.genera
    end
    @genus = params[:genus]
    @genus = Taxon.find @genus if @genus

    # species column
    case @genus
    when nil
      @specieses = nil
    else
      @specieses = @genus.species
    end
    @species = params[:species]
    @species = Taxon.find @species if @species

    # save the column selections
    @column_selections = {:subfamily => @subfamily, :tribe => @tribe, :genus => @genus, :species => @species}
      #:q => params[:q], :search_type => params[:search_type], :hide_tribes => params[:hide_tribes]}

    #case @taxon
    #when 'no_subfamily', Subfamily
      if @subfamily == 'none'
      #elsif params[:hide_tribes]
        #@genera = @selected_subfamily.genera
      #else
        #@tribes = @selected_subfamily.tribes
      end

    #when 'no_tribe', Tribe
      #@selected_tribe = @taxon
      #if params[:hide_tribes] && @selected_tribe == 'no_tribe'
        #@taxon = ::Subfamily.find params[:subfamily]
        #@selected_subfamily = @taxon
        #@genera = @selected_subfamily.genera
      #elsif params[:hide_tribes]
        #@taxon = @selected_tribe.subfamily
        #@selected_subfamily = @taxon
        #@genera = @selected_subfamily.genera
      #elsif @selected_tribe == 'no_tribe'
        #@selected_subfamily = ::Subfamily.find params[:subfamily]
        #@tribes = @selected_subfamily.tribes
        #@genera = @selected_subfamily.genera.without_tribe
      #else
        #@tribes = @selected_tribe.siblings
        #@genera = @selected_tribe.genera
        #@selected_subfamily = @selected_tribe.subfamily
      #end

    #when Genus
      #@selected_genus = @taxon
      #select_subfamily_and_tribes
      #select_genera
      #@species = @selected_genus.species

    #when Species
      #@selected_species = @taxon
      #@selected_genus = @selected_species.genus
      #@species = @selected_species.siblings
      #select_subfamily_and_tribes
      #select_genera

    #when nil
    #end

    #@column_selections[:subfamily] = @selected_subfamily


  end

  #def select_subfamily_and_tribes
    #@selected_subfamily = @selected_genus.subfamily || 'no_subfamily'
    #unless params[:hide_tribes] || @selected_subfamily == 'no_subfamily'
      #@selected_tribe = @selected_genus.tribe || 'no_tribe'
      #@tribes = @selected_subfamily.tribes
    #end
  #end

  #def select_genera
    #if @selected_subfamily == 'no_subfamily'
      #@genera = Genus.without_subfamily
    #elsif params[:hide_tribes]
      #@genera = @selected_subfamily.genera
    #else
      #@genera = @selected_genus.siblings
    #end
  #end

  #def select_subfamily_and_tribes
    #@selected_subfamily = @selected_genus.subfamily || 'no_subfamily'
    #unless params[:hide_tribes] || @selected_subfamily == 'no_subfamily'
      #@selected_tribe = @selected_genus.tribe || 'no_tribe'
      #@tribes = @selected_subfamily.tribes
    #end
  #end

  #def select_genera
    #if @selected_subfamily == 'no_subfamily'
      #@genera = Genus.without_subfamily
    #elsif params[:hide_tribes]
      #@genera = @selected_subfamily.genera
    #else
      #@genera = @selected_genus.siblings
    #end
  #end

  #def select_subfamily_and_tribes
    #@selected_subfamily = @selected_genus.subfamily || 'no_subfamily'
    #unless params[:hide_tribes] || @selected_subfamily == 'no_subfamily'
      #@selected_tribe = @selected_genus.tribe || 'no_tribe'
      #@tribes = @selected_subfamily.tribes
    #end
  #end

  #def select_genera
    #if @selected_subfamily == 'no_subfamily'
      #@genera = Genus.without_subfamily
    #elsif params[:hide_tribes]
      #@genera = @selected_subfamily.genera
    #else
      #@genera = @selected_genus.siblings
    #end
  #end

end

