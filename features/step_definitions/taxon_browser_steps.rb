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
  all_panels = accordion.find_all(".accordion-item")
  open_panels = accordion.find_all(".accordion-item.is-active")

  expect(all_panels.size).to eq open_panels.size
end

When /^I click on the (family|subfamily|genus|species) panel$/ do |rank|
  find(".#{rank.pluralize}-test-hook", visible: true).click
end

Then /^I should see the (family|subfamily|genus|species) panel (opened|closed)$/ do |rank, state|
  selector = ".#{rank.pluralize}-test-hook.is-active"

  case state
  when "opened"
    page.should have_css(selector, visible: true)
  when "closed"
    page.should have_no_css(selector, visible: true)
  else
    raise "use (open|closed), not '#{state}'"
  end
end
