# frozen_string_literal: true

module QuickAdd
  class FromExistingSubspeciesProtonym
    def initialize protonym
      @protonym = protonym
    end

    def can_add?
      return @_can_add if defined?(@_can_add)

      @_can_add ||= begin
        parent_name_string && parent.present?
      end
    end

    def taxon_form_params
      {
        rank_to_create: rank,
        status: status,
        parent_id: parent.id,
        taxon_name_string: cleaned_protonym_name,
        current_taxon_id: current_taxon&.id,
        protonym_id: protonym.id,
        fossil: protonym.fossil,
        original_combination: true,
        edit_summary: "[semi-automatic] Quick-add missing obsolete combination for protonym"
      }
    end

    def rank
      Rank::SUBSPECIES
    end

    def synopsis
      return failure_message unless can_add?
      success_message
    end

    private

      attr_reader :protonym

      def status
        Status::OBSOLETE_COMBINATION
      end

      def parent
        return @_parent if defined?(@_parent)
        @_parent ||= possible_parents.first if possible_parents_count == 1
      end

      def possible_parents
        Species.where(name_cache: parent_name_string)
      end

      def possible_parents_count
        @_possible_parents_count ||= possible_parents.count
      end

      def parent_name_string
        @_parent_name_string ||= cleaned_protonym_name.split[0..1].join(' ')
      end

      def current_taxon
        most_accepted_taxa.joins(:name).where(type: Rank::SPECIES, names: { epithet: epithet }).first
      end

      def cleaned_protonym_name
        @_cleaned_protonym_name ||= protonym.name.cleaned_name
      end

      def epithet
        @_epithet ||= cleaned_protonym_name.split.last
      end

      def most_accepted_taxa
        protonym.taxa.
          where(status: ['unavailable', 'homonym', 'synonym', 'valid']).
          order("FIELD(status, 'unavailable', 'homonym', 'synonym', 'valid')")
      end

      # ---

      def success_message
        <<~SYNOPSIS
          <b>Name</b>: #{cleaned_protonym_name}<br>
          <b>Status</b>: #{status}<br>
          <b>Parent</b>: #{CatalogFormatter.link_to_taxon(parent)}<br>
          #{current_taxon_synopsis}<br>
        SYNOPSIS
      end

      def current_taxon_synopsis
        current_taxon_link = CatalogFormatter.link_to_taxon(current_taxon) if current_taxon
        current_taxon_status = current_taxon&.status || '???'

        <<~SYNOPSIS
          <b>Current taxon</b>: #{current_taxon_link}<br>
          <b>Current taxon status</b>: #{current_taxon_status}<br>
        SYNOPSIS
      end

      def failure_message
        case possible_parents_count
        when 0 then "Found no parent - #{parent_name_string}"
        when 1 then "This message should never be seen???????"
        else        "Found more than one parent - #{parent_name_string}"
        end
      end
  end
end
