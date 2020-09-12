# frozen_string_literal: true

module DatabaseScripts
  class UnparsableNames < DatabaseScript
    PARSE_ALL_NAMES = false # TODO: Check with `true` before getting rid of this script.

    def results
      unparsable_names = []

      name_scope.each do |name|
        parsed_name = Names::BuildNameFromString[name.name]
        different = (name.name != parsed_name.name) || name.class != parsed_name.class
        unparsable_names << [name, parsed_name] if different
      rescue Names::BuildNameFromString::UnparsableName
        unparsable_names << [name, nil]
      end

      unparsable_names
    end

    def render
      as_table do |t|
        t.header 'Name', 'Type', 'Parsed as different type', 'Owner type', 'Comment', "Flagged as 'Non-conforming'?"
        t.rows do |(name, parsed_name)|
          owner_type = name.id.in?(name_ids_owned_by_protonyms) ? 'Protonym' : 'Taxon'
          comment = name_comment(name, parsed_name)

          [
            link_to(name.name, name_path(name)),
            name.type,
            (parsed_name.type if parsed_name && parsed_name.class != name.class),
            owner_type,
            comment,
            ('Yes' if name.non_conforming?)
          ]
        end
      end
    end

    private

      def name_scope
        return Name.all if PARSE_ALL_NAMES

        # TODO: Cheating a little bit for performance-reasons now that all species-group names have been fixed.
        Name.where.not(type: Name::SPECIES_GROUP_NAMES)
      end

      def name_ids_owned_by_protonyms
        @_name_ids_owned_by_protonyms ||= Name.joins(:protonyms).pluck(:id)
      end

      def name_comment name, parsed_name
        if parsed_name.nil?
          '100% unparsable name (could not even be misidentified)'
        elsif valid_subtribe_name?(name)
          'OK - subtribe name that is valid'
        end
      end

      def valid_subtribe_name? name
        name.is_a?(SubtribeName) && Subtribe.valid_subtribe_name?(name.name)
      end
  end
end

__END__

section: pa-action-required
category: Names
tags: [high-priority]

description: >
  Many of these records can only be fixed by script.

related_scripts:
  - UnparsableNames
