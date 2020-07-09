# frozen_string_literal: true

module Names
  class CleanName
    include Service

    SUBGENUS_NAME_REGEX = /^[A-Z][a-z]+ \((?<subgenus_part_of_name>[A-Z][a-z]+)\)$/

    attr_private_initialize :name

    def call
      return if name.blank?
      return subgenus_part_of_name if subgenus_name?

      clean_name
    end

    private

      def clean_name
        name.
          downcase.
          gsub(/\(.*?\)/, '').
          gsub(/ #{Regexp.union(Name::RANK_ABBREVIATIONS)} /, ' ').
          squish.
          capitalize
      end

      def subgenus_name?
        name.match?(SUBGENUS_NAME_REGEX)
      end

      def subgenus_part_of_name
        name.scan(SUBGENUS_NAME_REGEX).flatten.first
      end
  end
end
