# frozen_string_literal: true

module QuickAdd
  class FromHardcodedNameFactory
    def self.create_quick_adder name_string
      identified_name_class = Names::IdentifyNameType[name_string]

      case identified_name_class.name
      when 'SubgenusName'
        QuickAdd::FromHardcodedSubgenusName.new(name_string)
      else
        QuickAddRankNotSupported.new(name_string, identified_name_class)
      end
    end

    class QuickAddRankNotSupported
      def initialize name_string, name_class
        @name_string = name_string
        @name_class = name_class
      end

      def can_add?
        false
      end

      def synopsis
        error_message
      end

      private

        attr_reader :name_string, :name_class

        def error_message
          "Identified as #{name_class.name} (not supported)"
        end
    end
  end
end
