Given("there is a genus {string} that's waiting for approval") do |name|
  genus_name = create :genus_name, name: name
  genus = create :genus, :waiting, name: genus_name

  user = User.first
  change = create :change, taxon: genus, user: user
  create :version, item_id: genus.id, whodunnit: user.id, change_id: change.id
end
