class TaxonDecorator < Draper::Decorator
  include Draper::LazyHelpers
  include ERB::Util
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  delegate_all

  require_relative 'taxon/child_list'
  require_relative 'taxon/header'
  require_relative 'taxon/headline'
  require_relative 'taxon/history'
  require_relative 'taxon/statistics'

  include AntwebRefactorHelper if $use_ant_web_formatter

  private def get_current_user
    helpers.current_user
    rescue NoMethodError
      nil
  end

  def header
    TaxonDecorator::Header.new(taxon, get_current_user).header
  end

  def statistics options = {}
    statistics = taxon.statistics or return ''
    string = TaxonDecorator::Statistics.new.statistics(statistics, options)
    helpers.content_tag :div, string, class: 'statistics'
  end

  def headline
    TaxonDecorator::Headline.new(taxon, get_current_user).headline
  end

  def child_lists
    TaxonDecorator::ChildList.new(taxon, get_current_user).child_lists
  end

  def history
    TaxonDecorator::History.new(taxon, get_current_user).history
  end

  def genus_species_header_notes_taxt
    if taxon.genus_species_header_notes_taxt.present?
      content_tag :div, detaxt(taxon.genus_species_header_notes_taxt), class: 'genus_species_header_notes_taxt'
    end
  end

  def references
    if taxon.reference_sections.present?
      content_tag :div, class: 'reference_sections' do
        taxon.reference_sections.inject(''.html_safe) do |content, section|
          content << reference_section(section)
        end
      end
    end
  end

  def change_history
    return if taxon.old?
    change = taxon.latest_change
    return unless change
    content_tag :span, class: 'change_history' do
      content = ''.html_safe
      if (change.change_type == 'create')
        content << "Added by"
      else
        content << "Changed by"
      end
      content << " #{change.changed_by.decorate.format_doer_name} ".html_safe
      content << format_time_ago(change.created_at).html_safe

      if taxon.approved?
        # I don't fully understand this case;
        # it appears that somehow, we're able to generate "changes" without affiliated taxon_states.
        # not clear to me how this happens or whether this should be allowed.
        # Workaround: If the taxon_state is showing "approved", go get the most recent change that
        # has a noted approval.
        approved_change = Change.where('user_changed_taxon_id = ? and approved_at is not null', change.user_changed_taxon_id).last

        content << "; approved by #{approved_change.approver.decorate.format_doer_name} ".html_safe
        content << format_time_ago(approved_change.approved_at).html_safe
      end

      content
    end
  end

  private
    def reference_section section
      content_tag :div, class: 'section' do
        [:title_taxt, :subtitle_taxt, :references_taxt].inject(''.html_safe) do |content, field|
          if section[field].present?
            content << content_tag(:div, detaxt(section[field]), class: field)
          end
          content
        end
      end
    end

    def detaxt taxt
      return '' unless taxt.present?
      Taxt.to_string taxt, get_current_user
    end
end
