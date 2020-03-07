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
        t.header :name, :type, :parsed_as_different_type, :owner_type, :will_be_fixed_by_itself?, :unparsable?
        t.rows do |(name, parsed_name)|
          owner_type = name.id.in?(name_ids_owned_by_protonyms) ? 'Protonym' : 'Taxon'

          [
            link_to(name.name, name_path(name)),
            name.type,
            (parsed_name.type if parsed_name && parsed_name.class != name.class),
            owner_type,
            will_be_fixed_by_itself(name, parsed_name, owner_type),
            ('Yes' unless parsed_name)
          ]
        end
      end
    end

    private

      def name_ids_owned_by_protonyms
        @name_ids_owned_by_protonyms ||= Name.joins(:protonyms).pluck(:id)
      end

      def will_be_fixed_by_itself name, parsed_name, owner_type
        if name.is_a?(SubspeciesName) && parsed_name.is_a?(InfrasubspeciesName) && name.name == parsed_name.name
          owner_type == 'Taxon' ? 'Yes' : 'By script'
        end
      end
  end
end

__END__

category: Names
tags: [very-slow]

description: >
  These records can only be fixed by script.


  `SubspeciesName`s parsed as `InfrasubspeciesName`s will be fixed once we have converted all quadrinomials.

related_scripts:
  - UnparsableNames
