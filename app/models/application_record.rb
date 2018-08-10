class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def make_not_auto_generated!
    return unless auto_generated?
    self.auto_generated = false
    save
  end

  private

    def copy_attributes_from from_object, *attributes_to_copy
      attributes_to_copy.each do |attribute|
        send "#{attribute}=".to_sym, from_object.send(attribute)
      end
    end

    def copy_attributes_to to_object, *attributes_to_copy
      attributes_to_copy.each do |attribute|
        to_object.send "#{attribute}=".to_sym, send(attribute)
      end
    end
end
