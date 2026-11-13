# frozen_string_literal: true

# Whether a species can be converted to a subspecies (it must be a species without subspecies), with the reasons
# when it cannot.
class ConvertToSubspeciesPolicy
  attr_private_initialize :taxon

  def errors
    lazy_errors.to_a
  end

  def allowed?
    !lazy_errors.find(&:present?)
  end

  private

    def lazy_errors
      Enumerator.new do |yielder|
        yielder << 'taxon is not a species' unless taxon.is_a?(Species)
        yielder << 'taxon has subspecies' if taxon.is_a?(Species) && taxon.subspecies.exists?
      end
    end
end
