class Issue < ApplicationRecord
  include RevisionsCanBeCompared
  include Trackable

  TITLE_MAX_LENGTH = 100

  belongs_to :adder, class_name: "User"
  belongs_to :closer, class_name: "User"

  validates :adder, :description, presence: true
  validates :title, presence: true, length: { maximum: TITLE_MAX_LENGTH }

  scope :open, -> { where(open: true) }
  scope :by_status_and_date, -> { order(open: :desc, created_at: :desc) }
  scope :open_help_wanted, -> { open.where(help_wanted: true) }

  acts_as_commentable
  has_paper_trail
  trackable parameters: proc { { title: title } }

  def self.help_wanted?
    open_help_wanted.any?
  end

  def closed?
    !open?
  end

  def close! user
    update!(open: false, closer: user)
  end

  def reopen!
    update!(open: true, closer: nil)
  end

  # Read-only alias for `Comment#notify_commentable_creator`.
  def user
    adder
  end
end
