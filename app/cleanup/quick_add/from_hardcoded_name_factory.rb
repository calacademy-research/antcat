# frozen_string_literal: true

module QuickAdd
  class FromHardcodedNameFactory
    def self.create_quick_adder name_string
      identified_name_class = Names::IdentifyNameType[name_string]

      case identified_name_class.name
      when 'SubgenusName'
        QuickAdd::FromHardcodedSubgenusName.new(name_string)
      else
        if epithet? name_string
          QuickAdd::QuickAddNotSupported.new("Identified as 'epithet' (not supported)")
        else
          QuickAdd::QuickAddNotSupported.new("Identified as #{identified_name_class.name} (not supported)")
        end
      end
    end

    def self.epithet? name_string
      name_string.split.size == 1 && name_string.downcase == name_string
    end
  end
end
