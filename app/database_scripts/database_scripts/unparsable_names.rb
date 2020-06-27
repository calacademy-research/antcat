# frozen_string_literal: true

module DatabaseScripts
  class UnparsableNames < DatabaseScript
    def results
      unparsable_names = []

      Name.all.each do |name|
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
        t.header 'Name', 'Type', 'Parsed as different type', 'Owner type', 'Convert?', 'Will be fixed by itself?', 'Unparsable?'
        t.rows do |(name, parsed_name)|
          owner_type = name.id.in?(name_ids_owned_by_protonyms) ? 'Protonym' : 'Taxon'

          [
            link_to(name.name, name_path(name)),
            name.type,
            (parsed_name.type if parsed_name && parsed_name.class != name.class),
            owner_type,
            ('Convert!' if convert_by_script?(name, parsed_name, owner_type)),
            will_be_fixed_by_itself(name, parsed_name, owner_type),
            ('Yes' unless parsed_name)
          ]
        end
      end
    end

    private

      def name_ids_owned_by_protonyms
        @_name_ids_owned_by_protonyms ||= Name.joins(:protonyms).pluck(:id)
      end

      def will_be_fixed_by_itself name, parsed_name, owner_type
        if name.is_a?(SubspeciesName) && parsed_name.is_a?(InfrasubspeciesName) && name.name == parsed_name.name
          owner_type == 'Taxon' ? 'Yes' : 'By script'
        end
      end

      def convert_by_script? name, parsed_name, owner_type
        return false unless owner_type == 'Protonym'

        (name.type == 'SubspeciesName' && parsed_name.class.name == 'SpeciesName') ||
          (name.type == 'SpeciesName' && parsed_name.class.name == 'SubspeciesName')
      end
  end
end

__END__

section: pa-action-required
category: Names
tags: [very-slow, high-priority]

description: >
  These records can only be fixed by script.


  `SubspeciesName`s parsed as `InfrasubspeciesName`s will be fixed once we have converted all quadrinomials.


  Other records disagree with the parsed name for various reasons, and will be fixed in batches.


  Issue: %github837

related_scripts:
  - UnparsableNames
