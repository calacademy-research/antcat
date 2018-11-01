class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  private

    def copy_attributes_to to_object, *attributes_to_copy
      attributes_to_copy.each do |attribute|
        to_object.send "#{attribute}=".to_sym, send(attribute)
      end
    end
end
