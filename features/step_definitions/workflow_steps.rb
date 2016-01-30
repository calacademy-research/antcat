When /^(?:that )?version tracking is (not)?enabled$/ do |is_not|
  PaperTrail.enabled = !is_not
end

When /^the changes are approved$/ do
  TaxonState.update_all review_state: :approved
  Change.update_all approver_id: @user.id, approved_at: Time.now
end

Given /^there is a genus "([^"]*)" that's waiting for approval$/ do |name|
  genus = create_genus name
  genus.taxon_state.review_state = :waiting
  genus.save
  change = FactoryGirl.create :change, user_changed_taxon_id: genus.id
  whodunnit = User.first.id
  version = FactoryGirl.create :version, item_id: genus.id, whodunnit: whodunnit, change_id: change.id
end

####
def should_see_in_changes selector, value
  page.should have_css selector, text: value
end

Then /^I should see the name "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.name', value
end
Then(/^I should see the genus "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.parent_rank', 'Genus'
  page.should have_css '.parent', text: value
end
Then /^I should see the subfamily "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.parent_rank', 'Subfamily'
  page.should have_css '.parent', text: value
end
Then /^I should see the status "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.status', value
end
Then /^I should see the incertae sedis status of "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.incertae_sedis', value
end
Then /^I should see the attribute "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.attributes', value
end
Then /^I should see the notes "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.notes', value
end
Then /^I should see the protonym name "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.protonym_name', value
end
Then /^I should see the protonym attribute "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.protonym_attributes', value
end
Then /^I should see the authorship reference "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.authorship_reference', value
end
Then /^I should see the page "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.page', value
end
Then /^I should see the forms "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.forms', value
end
Then /^I should see the locality "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.locality', value
end
Then /^I should see the authorship notes "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.authorship_notes', value
end
Then /^I should see the type name "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.type_name', value
end
Then /^I should see the type attribute "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.type_attributes', value
end
Then /^I should see the type notes "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.type_notes', value
end
Then /^I should see a history item "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.history_item', value
end
Then /^I should see a reference section "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.references_taxt', value
end

#############################
# editing
When /^I add the genus "([^"]+)"?$/ do |genus_name|
  reference = FactoryGirl.create :article_reference

  taxon_params = HashWithIndifferentAccess.new(
      name_attributes: {id: ''},
      status: 'valid',
      incertae_sedis_in: '',
      fossil: '0',
      nomen_nudum: '0',
      unresolved_homonym: '0',
      ichnotaxon: '0',
      hong: '0',
      headline_notes_taxt: '',
      current_valid_taxon_name_attributes: {id: ''},
      homonym_replaced_by_name_attributes: {id: ''},
      protonym_attributes: {
          name_attributes: {id: ''},
          fossil: '0',
          sic: '0',
          locality: '',
          authorship_attributes: {
              reference_attributes: {id: reference.id},
              pages: '',
              forms: '',
              notes_taxt: '',
          },
      }
  )
  genus_params = taxon_params.deep_dup
  genus_params[:name_attributes][:id] = FactoryGirl.create(:genus_name, name: genus_name).id
  genus_params[:protonym_attributes][:name_attributes][:id] = FactoryGirl.create(:genus_name, name: 'Betta').id
  genus_params[:type_name_attributes] = {id: FactoryGirl.create(:species_name, name: 'Betta major').id}

  taxon = mother_replacement_create_taxon Rank[:genus], create_subfamily
  taxon.save_taxon(genus_params)

  taxon.last_change.versions.each do |version|
    version.update_attributes whodunnit: @user.id
  end
end

# from ex TaxonMother
# TODO replace with factory?
def mother_replacement_create_taxon rank, parent
  taxon = rank.string.titlecase.constantize.new
  taxon.parent = parent
  taxon.build_name
  taxon.build_type_name
  taxon.build_protonym
  taxon.protonym.build_name
  taxon.protonym.build_authorship
  taxon
end

Then /I should not see any change history/ do
  page.should_not have_css '.change_history'
end
