# coding: UTF-8
class ForwardRefFromTaxt < ForwardRef

  belongs_to :name; validates :name, presence: true

  def fixup
    fixee[fixee_attribute] = fixee[fixee_attribute].gsub(/{fwd #{id}/) do |match|
      "{tax #{Taxon.find_name(name.name).id}}"
    end
    fixee.save!
  end

end
