# coding: UTF-8
class Formatters::TaxonFormatter
  include ActionView::Helpers::TagHelper
  include ActionView::Context

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

  def child_lists
    @taxon.decorate.child_lists
  end

  def references
    @taxon.decorate.references
  end

  def history
    @taxon.decorate.history
  end

  def header
    @taxon.decorate.header
  end

  def change_history
    @taxon.decorate.change_history
  end

  private
    def detaxt taxt #for AntWeb exporter
      return '' unless taxt.present?
      Taxt.to_string taxt, @user, expansion: false, formatter: Exporters::Antweb::Formatter
    end

end
