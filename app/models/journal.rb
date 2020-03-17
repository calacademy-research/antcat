class Journal < ApplicationRecord
  include Trackable

  has_many :references, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: true }

  scope :includes_reference_count, -> do
    left_joins(:references).group(:id).
      select("journals.*, COUNT(references.id) AS reference_count")
  end

  has_paper_trail
  trackable parameters: proc {
    { name: name, name_was: (name_before_last_save if saved_change_to_name?) }
  }

  def invalidate_reference_caches!
    references.find_each do |reference|
      References::Cache::Invalidate[reference]
    end
  end
end
