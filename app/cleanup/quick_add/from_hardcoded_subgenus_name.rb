# frozen_string_literal: true

# TMPCLEANUP: Temporary code for `DatabaseScripts::MissingTaxaToBeCreated`.
module QuickAdd
  class FromHardcodedSubgenusName
    def initialize name_string
      @name_string = name_string
    end

    def can_add?
      return @_can_add if defined?(@_can_add)

      @_can_add ||= begin
        parent_name_string && possible_parents_count == 1
      end
    end

    def name_class
      @_name_class ||= Names::IdentifyNameType[name_string]
    end

    def taxon_class
      @_taxon_class ||= name_class.name.delete_suffix('Name').constantize
    end

    def taxon_form_params
      {
        rank_to_create: taxon_class,
        parent_id: parent.id,
        taxon_name_string: name_string,
        status: status,
        protonym_id: protonym&.id,
        current_taxon_id: current_taxon&.id,
        edit_summary: "[semi-automatic] Quick-add missing name"
      }
    end

    def synopsis
      return failure_message unless can_add?
      success_message
    end

    private

      attr_reader :name_string

      def status
        Status::OBSOLETE_COMBINATION
      end

      def parent
        return @_parent if defined?(@_parent)
        @_parent ||= possible_parents.first if possible_parents_count == 1
      end

      def parent_name_string
        name_string.split.first
      end

      def possible_parents
        Genus.where(name_cache: parent_name_string)
      end

      def possible_parents_count
        @_possible_parents_count ||= possible_parents.count
      end

      def protonym
        return @_protonym if defined?(@_protonym)
        @_protonym ||= possible_protonyms.first if possible_protonyms.count == 1
      end

      def protonym_name_string
        name_string.split.last.tr('()', '')
      end

      def possible_protonyms
        Protonym.joins(:name).where(names: { name: protonym_name_string })
      end

      def current_taxon
        return @_current_taxon if defined?(@_current_taxon)
        @_current_taxon ||= possible_current_taxa.first if possible_current_taxa.count == 1
      end

      def current_taxon_name_string
        name_string.split.last.tr('()', '')
      end

      def possible_current_taxa
        Taxon.where(name_cache: current_taxon_name_string)
      end

      # ---

      def success_message
        protonym_line =
          if protonym
            protonym.decorate.link_to_protonym + ' ' + protonym.author_citation
          else
            '???'
          end

        current_taxon_line =
          if current_taxon
            "#{CatalogFormatter.link_to_taxon(current_taxon)} #{current_taxon.author_citation}"
          else
            '???'
          end

        <<~SYNOPSIS
          <b>Name</b>: #{name_class.new(name: name_string).name_html}<br>
          <b>Rank</b>: #{taxon_class} <small>(via <code>#{self.class.name.demodulize}</code>)</small><br>
          <b>Parent</b>: #{CatalogFormatter.link_to_taxon(parent)}<br>
          <b>Status</b>: #{status}<br>
          <b>Current taxon</b>: #{current_taxon_line}<br>
          <b>Protonym</b>: #{protonym_line}<br>
        SYNOPSIS
      end

      def failure_message
        case possible_parents_count
        when 0 then "Found no parent - #{parent_name_string}"
        when 1 then "This message should never be seen???????"
        else        "Found more than one - #{parent_name_string}"
        end
      end
  end
end
