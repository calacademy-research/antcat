# coding: UTF-8
class ReviewStatus

  def initialize attributes
    @attributes = attributes
  end

  def value
    @attributes[:string]
  end

  def display_string
    @attributes[:display_string]
  end

  def self.find string
    review_statuses.find {|review_status| review_status.value == string} or raise "Couldn't find #{string}"
  end
  class << self; alias_method :[], :find end

  def self.review_statuses
    @_review_statuses ||= [
      ReviewStatus.new(string: 'None', display_string: 'None'),
      ReviewStatus.new(string: 'Reviewing',  display_string: 'Reviewing'),
    ]
  end

end
