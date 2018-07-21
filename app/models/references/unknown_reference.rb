class UnknownReference < Reference
  validates :year, :citation, presence: true
end
