class Bolton::SubfamilyCatalog < Bolton::Catalog
  private

  def parse_subgenera genus
    return '' unless @type == :subgenera_header
    Progress.log 'parse_subgenera'
    ''
  end
end
