# coding: UTF-8
class ForwardRef < ActiveRecord::Base

  belongs_to :fixee, polymorphic: true; validates :fixee, presence: true
  validates  :fixee_attribute, presence: true

  def self.fixup
    all.each &:fixup
  end

end
