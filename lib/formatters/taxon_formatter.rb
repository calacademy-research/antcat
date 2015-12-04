# coding: UTF-8
class Formatters::TaxonFormatter
  include ActionView::Helpers::TagHelper
  extend ActionView::Helpers::TagHelper
  include ActionView::Context
  include Formatters::Formatter
  extend Formatters::Formatter
  include Formatters::LinkFormatter
  extend Formatters::LinkFormatter

  def initialize taxon, user = nil
    @taxon, @user = taxon, user
  end

  def statistics options = {}
    @taxon.decorate.statistics options
  end

  def genus_species_header_notes_taxt
    @taxon.decorate.genus_species_header_notes_taxt
  end

  def headline
    @taxon.decorate.headline
  end

  def history
    @taxon.decorate.history
  end

  def child_lists
    @taxon.decorate.child_lists
  end

  def references
    @taxon.decorate.references
  end

end