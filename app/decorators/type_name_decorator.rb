# frozen_string_literal: true

class TypeNameDecorator < Draper::Decorator
  delegate :taxon, :fixation_method, :reference, :pages

  def format_rank
    "#{format_just_rank}: ".html_safe
  end

  def format_just_rank
    "Type-#{taxon.rank}".html_safe
  end

  def compact_taxon_status
    return '' if (compact_status = most_recent_before_now_taxon.decorate.compact_status).blank?

    prefix = "now: " if show_now_prefix?
    " (#{prefix}".html_safe + compact_status + ')'.html_safe
  end

  def format_fixation_method
    return '' unless fixation_method

    case fixation_method
    when TypeName::BY_MONOTYPY
      ', by monotypy.'
    when TypeName::BY_ORIGINAL_DESIGNATION
      ', by original designation.'
    when TypeName::BY_SUBSEQUENT_DESIGNATION_OF
      ', by subsequent designation of ' + citation_for_by_subsequent_designation_of + '.'
    else raise '????'
    end
  end

  private

    # TODO: This belongs somewhere else or nowhere at all.
    def show_now_prefix?
      return false if most_recent_before_now_taxon == taxon
      return false if most_recent_before_now_taxon == taxon.now_taxon

      true
    end

    def most_recent_before_now_taxon
      @_most_recent_before_now_taxon ||= taxon.most_recent_before_now_taxon
    end

    # TODO: Cheating a lot to quickly make it work on the site and in the AntWeb export at the same time.
    def citation_for_by_subsequent_designation_of
      "#{Taxt.ref(reference.id)}: #{pages}"
    end
end
