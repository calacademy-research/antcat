# This decorator is mainly responsible for formatting the top part of catalog pages (via
# app/views/catalog/_taxon.haml), but is also used elsewhere (eg lib/exporters/antweb/exporter.rb).
# See the bottom of this file for some notes.
#
# December 2015: All "sub decorators" (such as ChildList, Headline) were originally intended
# for isolating logical chunks into smaller units only while migrating all Formatters to
# Decorators (refer to the change log for commit ids). The code is not terrible (and surely
# an improvement), but we still need (want) that encapsulation.

class TaxonDecorator < ApplicationDecorator
  include TaxonDecorator::EditorButtons
  delegate_all

  def link_to_taxon
    label = taxon.name.to_html_with_fossil(taxon.fossil?)
    helpers.content_tag :a, label, href: %{/catalog/#{taxon.id}}
  end

  def header
    TaxonDecorator::Header.new(taxon, get_current_user).header
  end

  def statistics options = {}
    statistics = taxon.statistics
    return '' unless statistics
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
    return unless taxon.genus_species_header_notes_taxt.present?
    helpers.content_tag :div, detaxt(taxon.genus_species_header_notes_taxt), class: 'genus_species_header_notes_taxt'
  end

  def references
    return unless taxon.reference_sections.present?
    helpers.content_tag :div, class: 'reference_sections' do
      taxon.reference_sections.inject(''.html_safe) do |content, section|
        content << reference_section(section)
      end
    end
  end

  def change_history
    return if taxon.old?
    change = taxon.latest_change
    return unless change

    helpers.content_tag :span, class: 'change_history' do
      content = ''.html_safe
      if change.change_type == 'create'
        content << "Added by"
      else
        content << "Changed by"
      end
      content << " #{change.decorate.format_changed_by} ".html_safe
      content << change.decorate.format_created_at.html_safe

      if taxon.approved?
        # I don't fully understand this case;
        # it appears that somehow, we're able to generate "changes" without affiliated
        # taxon_states. not clear to me how this happens or whether this should be allowed.
        # Workaround: If the taxon_state is showing "approved", go get the most recent change
        # that has a noted approval.
        approved_change = Change.where(<<-SQL.squish, change.user_changed_taxon_id).last
          user_changed_taxon_id = ? AND approved_at IS NOT NULL
        SQL
        content << "; approved by #{approved_change.decorate.format_approver_name} ".html_safe
        content << approved_change.decorate.format_approved_at.html_safe
      end

      content
    end
  end

  def taxon_status
    # Note: Cleverness is used here to make these queries (e.g.: obsolete_combination?)
    # appear as tags. That's how CSS does its coloring.
    labels = []
    labels << "<i>incertae sedis</i> in #{Rank[taxon.incertae_sedis_in]}" if taxon.incertae_sedis_in
    if taxon.homonym? && taxon.homonym_replaced_by
      labels << "homonym replaced by #{taxon.homonym_replaced_by.decorate.link_to_taxon}"
    elsif taxon.unidentifiable?
      labels << 'unidentifiable'
    elsif taxon.unresolved_homonym?
      labels << "unresolved junior homonym"
    elsif taxon.nomen_nudum?
      labels << "<i>nomen nudum</i>"
    elsif taxon.synonym?
      label = 'junior synonym'
      label << format_senior_synonym
      labels << label
    elsif taxon.obsolete_combination?
      label = 'an obsolete combination of '
      label << format_valid_combination
      labels << label
    elsif taxon.unavailable_misspelling?
      label = 'a misspelling of '
      label << format_valid_combination
      labels << label
    elsif taxon.unavailable_uncategorized?
      label = 'see '
      label << format_valid_combination
      labels << label
    elsif taxon.nonconfirming_synonym?
      label = 'a non standard form of '
      label << format_valid_combination
      labels << label
    elsif taxon.invalid?
      label = Status[taxon].to_s.dup
      labels << label
    else
      labels << 'valid'
    end

    labels << 'ichnotaxon' if taxon.ichnotaxon?
    labels.join(', ').html_safe
  end

  def name_description
    string =
      case taxon
      when Subfamily
        'subfamily'
      when Tribe
        string = "tribe of "
        parent = taxon.subfamily
        string << (parent ? parent.name.to_html : '(no subfamily)')
      when Genus
        string = "genus of "
        parent = taxon.tribe ? taxon.tribe : taxon.subfamily
        string << (parent ? parent.name.to_html : '(no subfamily)')
      when Species
        string = "species of "
        parent = taxon.parent
        string << parent.name.to_html
       when Subgenus
         string = "subgenus of "
         parent = taxon.parent
         string << parent.name.to_html
      when Subspecies
        string = "subspecies of "
        parent = taxon.species
        string << (parent ? parent.name.to_html : '(no species)')
      else
        ''
      end

    # TODO: Joe test this case
    if taxon[:unresolved_homonym] == true && taxon.new_record?
      string = " secondary junior homonym of #{string}"
    elsif !taxon[:collision_merge_id].nil? && taxon.new_record?
      target_taxon = Taxon.find_by_id(taxon[:collision_merge_id])
      string = " merge back into original #{target_taxon.name_html_cache}"
    end

    string = "new #{string}" if taxon.new_record?
    string.html_safe
  end

  private
    def reference_section section
      helpers.content_tag :div, class: 'section' do
        [:title_taxt, :subtitle_taxt, :references_taxt].inject(''.html_safe) do |content, field|
          if section[field].present?
            content << helpers.content_tag(:div, detaxt(section[field]), class: field)
          end
          content
        end
      end
    end

    def detaxt taxt
      return '' unless taxt.present?
      Taxt.to_string taxt
    end

    def format_senior_synonym
      if current_valid_taxon = taxon.current_valid_taxon_including_synonyms
        return ' of current valid taxon ' << current_valid_taxon.decorate.link_to_taxon
      end
      ''
    end

    def format_valid_combination
      if current_valid_taxon = taxon.current_valid_taxon_including_synonyms
        return current_valid_taxon.decorate.link_to_taxon
      end
      ''
    end
end

# Example mentioned above. When ("if", heh) this becomes outdated and it takes more
# than 1 minute to update, please remove. From Aneuretinae:
#
# ---------- edit_buttons ----------
# Edit Delete
#
# ---------- header ----------
# Aneuretinae Emery, 1913 valid
#
# ---------- statistics ----------
# Extant: 1 valid tribe, 1 valid genus (1 unavailable misspelling), 1 valid species (1 synonym)
# Fossil: 1 valid tribe, 8 valid genera, 11 valid species
#
# ----------genus_species_header_notes_taxt -------------------
# # empty
#
# ---------- headline ----------
# Aneuretini Emery, 1913a: 6. Type-genus: Aneuretus. AntWeb AntWiki
#
# ---------- taxon.history_items.each { ... } ----------
# Aneuretinae as junior synonym of Dolichoderinae: Baroni Urbani, 1989: 147. Aneuretinae as ...
#
# ---------- child_lists ----------
# Tribe (extant) of Aneuretinae: Aneuretini.
# Tribe (extinct) of Aneuretinae: †Pityomyrmecini.
# Genera (extinct) incertae sedis in Aneuretinae: †Burmomyrma, †Cananeuretus.
#
# ---------- references ----------
# Subfamily references
# Boudinot, 2015: 49 (male diagnosis, discussion of *fossil taxa)
#
# ---------- change_history ----------
# Changed by Brendon E. Boudinot 9 months ago ...
#
#
# Bonus method for highlighting the different sections.
# Paste this beast dirtly into app/views/catalog/_taxon.haml:
=begin
-def highlight_for_debug content, caption = nil
  -content = caption.html_safe << content if caption
  -random_border_color_style = "border: 3px solid ##{"%06x" % (rand * 0xffffff)}"
  -content_tag :div, content, style: "#{random_border_color_style}"
=end
# ... and call like this:
# =highlight_for_debug taxon.headline
# =highlight_for_debug taxon.headline, "this is the headline" # optional
