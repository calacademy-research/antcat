# frozen_string_literal: true

module Names
  class BuildNameFromString
    include Service

    class UnparsableName < StandardError; end

    def initialize name
      @name = name&.squish
    end

    def call
      return Name.new if name.blank?
      raise UnparsableName, name unless name_class

      name_class.new(name: name)
    end

    private

      attr_reader :name

      def name_class
        @name_class ||= IdentifyNameType[name]
      end
  end
end
