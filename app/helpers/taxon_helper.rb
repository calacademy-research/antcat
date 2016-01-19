module TaxonHelper
  def sort_by_status_and_name taxa
    taxa.sort do |a, b|
      if a.status == b.status
        # name ascending
        a.name.name <=> b.name.name
      else
        # status descending
        b.status <=> a.status
      end
    end
  end
end
