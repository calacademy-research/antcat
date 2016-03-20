class Task < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  attr_reader :taxa_tokens

  belongs_to :adder, class_name: "User"
  belongs_to :closer, class_name: "User"

  has_many :task_references
  has_many :taxa, through: :task_references, source: :taxon

  validates :adder, presence: true
  validates :description, presence: true, allow_blank: false
  validates :title, presence: true, allow_blank: false, length: { maximum: 70 }
  validates_inclusion_of :status, in: %w(open closed completed)

  scope :open, -> { where(status: "open")._desc_date }
  scope :non_open, -> { where.not(status: "open")._desc_date }
  scope :_desc_date, ->  { order(created_at: :desc) }
  scope :by_status_and_date, -> do
    order(<<-SQL.squish)
      CASE WHEN status = 'open' THEN (9999 + created_at)
      ELSE created_at END DESC
    SQL
  end

  def taxa_tokens=(ids)
    self.taxa_ids = ids.split(",")
  end

  def open?
    status == "open"
  end

  def archived?
    status.in? ["completed", "closed"]
  end

  def set_status status, user
    self.status = status
    self.closer = status == "open" ? nil : user
    save!
  end
end
