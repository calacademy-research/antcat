module TestLinksHelpers
  def author_link author_name
    %(<a href="/authors/#{author_name.author.id}">#{author_name.name}</a>)
  end
end
