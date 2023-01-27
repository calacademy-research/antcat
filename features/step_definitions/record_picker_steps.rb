# frozen_string_literal: true

def set_record_picker record_id, css_selector
  if @current_example && @current_example.metadata[:js] # For RSpec.
    expect(page).to have_content "Pick" # HACK: Wait for page to load.
    page.execute_script("$('#{css_selector}').val(#{record_id})")
  else
    find(css_selector).set(record_id)
  end
end

def i_pick_from_the_taxon_picker name, input_css_selector
  taxon_id = Taxon.find_by!(name_cache: name).id

  set_record_picker taxon_id, input_css_selector
end

def i_pick_from_the_protonym_picker name, input_css_selector
  protonym_id = Protonym.joins(:name).find_by!(names: { name: name }).id

  set_record_picker protonym_id, input_css_selector
end

def i_pick_from_the_reference_picker key_with_year, input_css_selector
  last_name, year = key_with_year.split(',')
  reference = Reference.where("author_names_string_cache LIKE ?", "#{last_name}%").find_by!(year: year)

  set_record_picker reference.id, input_css_selector
end
