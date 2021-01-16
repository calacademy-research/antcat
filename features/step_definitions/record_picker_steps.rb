# frozen_string_literal: true

def set_record_picker record_id, css_selector
  if @cucumber_javascript_tag
    step 'I should see "Pick"' # HACK: Wait for page to load.
    page.execute_script("$('#{css_selector}').val(#{record_id})")
  else
    find(css_selector).set(record_id)
  end
end

When("I pick {string} from the {string} taxon picker") do |name, input_css_selector|
  taxon_id = Taxon.find_by!(name_cache: name).id

  set_record_picker taxon_id, input_css_selector
end

When("I pick {string} from the {string} protonym picker") do |name, input_css_selector|
  protonym_id = Protonym.joins(:name).find_by!(names: { name: name }).id

  set_record_picker protonym_id, input_css_selector
end

When("I pick {string} from the {string} reference picker") do |key_with_year, input_css_selector|
  reference_id = ReferenceStepsHelpers.find_reference_by_key(key_with_year).id

  set_record_picker reference_id, input_css_selector
end
