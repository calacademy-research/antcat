# frozen_string_literal: true

class NestedReference < Reference
  belongs_to :nesting_reference, class_name: 'Reference'

  validate :validate_nested_reference_doesnt_point_to_itself

  private

    def validate_nested_reference_doesnt_point_to_itself
      comparison = self
      while comparison&.nesting_reference_id
        if comparison.nesting_reference_id == id
          errors.add :nesting_reference_id, "can't point to itself"
          break
        end
        comparison = Reference.find_by(id: comparison.nesting_reference_id)
      end
    end
end
