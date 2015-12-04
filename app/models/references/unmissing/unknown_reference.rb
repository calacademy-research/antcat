# coding: UTF-8
class UnknownReference < UnmissingReference

  validates_presence_of :citation
  attr_accessible :year

end
