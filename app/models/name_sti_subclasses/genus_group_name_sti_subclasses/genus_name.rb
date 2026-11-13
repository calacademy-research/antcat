# frozen_string_literal: true

# The name of a genus.
class GenusName < GenusGroupName
  def genus_epithet
    cleaned_name_parts[0]
  end
end
