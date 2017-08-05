# *Very* messy script based on another very messy script.
# https://github.com/calacademy-research/antcat/blob/
# 0b1930a3e161e756e3c785bd32d6e54867cc480c/lib/tasks/database_maintenance.rake

require 'antcat_rake_utils'
include AntCat::RakeUtils

class DatabaseScripts::Scripts::BrokenTaxtTags
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include DatabaseScripts::DatabaseScript

  def results
    log.puts "Searching... (in '#{Rails.env}' database)\n\n"

    matched_ids_statistics = matched_ids.map do |tag, ids|
      "#{ids.size} #{tag}(s)"
    end.to_sentence

    log.puts "\nFound #{matched_ids_statistics} (unique only)."

    log.puts "\n----------"

    log.puts "\nSearching for non-existing..."
    broken_ids = taxt_tags.keys_plus_empty_arrays
    broken_ids.each_item_in_arrays_alias :each_id
    matched_ids.each do |tag, ids|
      broken_ids[tag] = reject_existing taxt_tags[tag], ids
    end

    if broken_ids.all? &:empty?
      log.puts "Found no broken tags."
      return "waddap"
    end

    broken_ids_statistics = broken_ids.map { |tag, ids| "#{ids.size} #{tag}(s)" }.to_sentence
    log.puts "\nFound #{broken_ids_statistics}."

    log.puts "\n----------"

    log.puts "\nListing which...\n\n"
    broken_ids.each { |tag, ids| log.puts "#{tag}: #{ids}" }

    log.puts "\n----------"

    log.puts "\nSearching destroyed...\n\n"
    broken_ids.each_id do |id, tag|
      PaperTrail::Version.where(event: 'destroy', item_type: taxt_tags[tag].to_s, item_id: id).each do |version|
        log.puts "Found #{tag} ##{id} (version id #{version.id}, #{version.event})"
      end
    end

    log.puts "\n----------"

    log.puts "\nSearching all versions...\n\n"
    broken_ids.each_id do |id, tag|
      PaperTrail::Version.where(item_id: id).each do |version|
        log.puts "Found #{tag} ##{id} (version id #{version.id})"
      end
    end

    log.puts "\n----------"

    log.puts "\nSearching for matching ids in other models (Reference, Name, Taxon)...\n\n"
    [Reference, Name, Taxon].each do |model|
      model.where(id: broken_ids.each_id).each do |item|
        log.puts "#{model.to_s}: #{item.id}"
      end
    end

    log.puts "\n----------"

    log.puts "\nListing affected taxa..."

    output.puts affected_taxa_table(taxa_with_broken_ids(broken_ids))

    log.puts "\nDone."

    output.string
  end

  def render
    markdown "<pre>#{results} #{log.string}</pre>"
  end

  private

    def output
      @_output ||= StringIO.new
    end

    def log
      @log ||= StringIO.new
    end

    def matched_ids
      @_matched_ids ||= begin
        ids = taxt_tags.keys_plus_empty_arrays
        models_with_taxts.each_field do |field, model|
          log.puts "    #{model} --> #{field}..."
          taxt_tags.each_key do |tag|
            ids[tag] += find_all_tagged_ids model, field, tag
          end
        end
        ids.each_value &:uniq!
        ids
      end
    end

    def taxa_with_broken_ids broken_ids
      taxon_id_field = {
        ReferenceSection => 'taxon_id',
        TaxonHistoryItem => 'taxon_id',
        Taxon            => 'id'
      }
      taxon_id_field.default = "id"

      taxa_with_broken_ids_thing = []
      models_with_taxts.each_field do |field, model|
        taxt_tags.each_key do |tag|
          model.where("#{field} LIKE '%{#{tag} %'").find_each do |matched_obj|
            matched_ids = extract_tagged_ids matched_obj.send(field), tag
            broken_matched_ids = matched_ids & broken_ids[tag]

            unless broken_matched_ids.empty?
              taxon = case matched_obj
                      when Citation then "Unknown"
                      else matched_obj.send(taxon_id_field[model]).to_i end

              taxa_with_broken_ids_thing << {
                item_id:            matched_obj.id,
                item_type:          model.to_s,
                taxon:              taxon,
                tag:                tag,
                field:              field,
                broken_matched_ids: broken_matched_ids
              }
            end
          end
        end
      end

      taxa_with_broken_ids_thing
    end

    def affected_taxa_table taxa_with_broken_ids
      as_table do
        header :item_id, :item_type, :taxon, :tag, :broken_ids

        rows(taxa_with_broken_ids) do |item|
          item_id                    = item[:item_id]
          item_type                  = item[:item_type]
          taxon                      = item[:taxon]
          tag                        = item[:tag]
          field                      = item[:field]
          broken_matched_ids         = item[:broken_matched_ids]

          [
            attempt_to_link_item(item_type, item_id),
            "`#{item_type}##{field}`",
            attemp_to_link_taxon(taxon, item_type, item_id),
            tag,
            attempt_to_link_broken_ids(tag, broken_matched_ids),
          ]
        end
      end
    end

    def attemp_to_link_taxon taxon, item_type, item_id
      taxon = Citation.find(item_id).protonym.taxon if item_type == "Citation"
      markdown_taxon_link(taxon)
    end

    def attempt_to_link_item item_type, item_id
      case item_type
      when "TaxonHistoryItem"
        link_to(item_id, taxon_history_item_path(item_id))
      when "ReferenceSection"
        link_to(item_id, reference_section_path(item_id))
      else
        item_id
      end
    end

    def attempt_to_link_broken_ids tag, broken_matched_ids
      broken_matched_ids.each_with_object("") do |id, string|
        case tag
        when :ref
          string << link_to("#{id} ", reference_history_index_path(id))
        when :tax
          string << link_to("#{id} ", taxon_history_path(id))
        else
          string << "#{id} "
        end
      end
    end

    def taxt_tags
      return @_taxt_tags if defined? @_taxt_tags

      @_taxt_tags = {
        ref: Reference,
        nam: Name,
        tax: Taxon,
        # epi: # TODO? /{epi (\w+)}/
        # ?:   # TODO? Not sure what this is, but it looks like this "{? #{string}}"
      }
      def @_taxt_tags.keys_plus_empty_arrays
        map { |tag, _| [tag, []] }.to_h
      end

      @_taxt_tags
    end
end

__END__
description: >
  Taxt tags (eg `{ref 133005}`) that are referred to but doesn't exist.
  See %github177.
tags: [very-slow]
topic_areas: [catalog, references]
