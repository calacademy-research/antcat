# frozen_string_literal: true

class GenusName < GenusGroupName
  def genus_epithet
    name_parts[0]
  end
end
