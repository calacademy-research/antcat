# coding: UTF-8
class ForwardRefFromTaxt < ForwardRef

  belongs_to :name; validates :name, presence: true

  def fixup
  end

end
