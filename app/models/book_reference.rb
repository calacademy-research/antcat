# coding: UTF-8
class BookReference < Reference
  belongs_to :publisher
  validates_presence_of :publisher, :pagination
end
