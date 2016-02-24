Then /^I should (not )?see the taxon browser$/ do |should_not|
  if should_not
    page.should have_no_css("#taxon_browser")
  else
    page.should have_css("#taxon_browser", visible: true)
  end
end

When /^I click the ?(tiny|mobile|desktop)? taxon browser toggler$/ do |size|
  size ||= "desktop"
  first("##{size}-toggler").click
end

Then /^I should see all taxon browser panels opened$/ do
  accordion = find("#taxon_browser ul.accordion")
  all_panels = accordion.find(".accordion-item")
  open_panels = accordion.find(".accordion-item.is-active")
  expect(open_panels).to eq all_panels
end
