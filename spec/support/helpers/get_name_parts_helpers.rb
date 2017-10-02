class GetNamePartsHelpers
  def self.get_name_parts name
    parts = name.split ' '
    epithet = parts.last
    epithets = parts[1..-1].join(' ') unless parts.size < 2
    return name, epithet, epithets
  end
end
