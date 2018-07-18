class NestedReference < Reference
  belongs_to :nesting_reference, class_name: 'Reference'

  validates_presence_of :year, :nesting_reference, :pages_in
  validate :validate_nested_reference_exists
  validate :validate_nested_reference_doesnt_point_to_itself

  def self.requires_title
    false
  end

  private

    def validate_nested_reference_exists
      nested_reference_exists = nesting_reference_id && Reference.find_by(id: nesting_reference_id)
      errors.add(:nesting_reference_id, 'does not exist') unless nested_reference_exists
    end

    def validate_nested_reference_doesnt_point_to_itself
      comparison = self
      while comparison && comparison.nesting_reference_id
        if comparison.nesting_reference_id == id
          errors.add :nesting_reference_id, "can't point to itself"
          break
        end
        comparison = Reference.find_by(id: comparison.nesting_reference_id)
      end
    end
end
