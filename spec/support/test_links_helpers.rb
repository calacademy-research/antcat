module TestLinksHelpers
  def author_link author_name
    %(<a href="/authors/#{author_name.author.id}">#{author_name.name}</a>)
  end

  def taxon_link taxon, label = nil
    %(<a href="/catalog/#{taxon.id}">#{label || taxon.name_with_fossil}</a>)
  end
end
