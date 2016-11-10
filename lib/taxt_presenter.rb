# This class is for parsing taxts in the "database format" (strings
# such as "hey {ref 123}") to something that can be read.

# TODO remove rescues.

class TaxtPresenter
  include ERB::Util
  include ActionView::Helpers::TagHelper
  include ApplicationHelper

  def initialize taxt_from_db
    @taxt = taxt_from_db
    @options = {}
  end
  class << self; alias_method :[], :new end

  # Parses "example {tax 429361}"
  # into   "example <a href=\"/catalog/429361\">Melophorini</a>"
  def to_html
    decode
  end

  # Parses "example {tax 429361}"
  # into   "example Melophorini"
  def to_text
    @options[:display] = true
    string = decode
    add_period_if_necessary string
  end

  # TODO coming soon, or not very soon!
  def to_antweb_export
    raise NotImplementedError
    @format = :antweb_export
    decode
  end

  private
    # TODO rename.
    def decode
      return '' unless @taxt.present?

      @taxt.gsub!(/{ref (\d+)}/) do |whole_match|
        decode_reference whole_match, $1
      end

      @taxt.gsub!(/{nam (\d+)}/) do |whole_match|
        decode_name whole_match, $1
      end

      @taxt.gsub!(/{tax (\d+)}/) do |whole_match|
        decode_taxon whole_match, $1
      end

      @taxt.gsub!(/{epi (\w+)}/) do |_|
      end

      @taxt.html_safe
    end

    def decode_reference whole_match, reference_id_match
      if @options[:display]
        reference = Reference.find(reference_id_match) rescue whole_match
        reference.decorate.keey rescue whole_match
      elsif $use_ant_web_formatter
        reference = Reference.find(reference_id_match) rescue whole_match
        reference.decorate.antweb_version_of_inline_citation rescue whole_match
      else
        reference = Reference.find(reference_id_match) rescue whole_match
        reference.decorate.inline_citation rescue whole_match
      end
    end

    def decode_name whole_match, name_id_match
      Name.find(name_id_match).to_html rescue whole_match
    end

    def decode_taxon whole_match, taxon_id_match
      if @options[:display]
        Taxon.find(taxon_id_match).name.to_html
      else
        taxon = Taxon.find taxon_id_match
        if $use_ant_web_formatter
          link_to_antcat_from_antweb taxon
        else
          taxon.decorate.link_to_taxon
        end
      end
    rescue
      whole_match
    end

    # TODO remove.
    def link_to_antcat_from_antweb taxon
      link_to_antcat taxon, taxon.name.to_html_with_fossil(taxon.fossil?).html_safe
    end
end
