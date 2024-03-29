# frozen_string_literal: true

module FeatureHelpers
  # Browser/navigation.
  def i_should_be_on page_name
    current_path = URI.parse(current_url).path
    expect(current_path).to eq page_name
  end

  def i_reload_the_page
    visit current_path
  end

  # Click/press/follow.
  def i_follow_the_first link_text
    first(:link, link_text, exact: true).click
  end

  def i_follow link_text, within_scope: nil
    if within_scope
      within within_scope do
        click_link link_text
      end
    else
      click_link link_text
    end
  end

  # "I should see / should contain".
  def i_should_see content, within_scope: nil
    if within_scope
      within within_scope do
        expect(page).to have_content content
      end
    else
      expect(page).to have_content content
    end
  end

  def i_should_not_see content, within_scope: nil
    if within_scope
      within within_scope do
        expect(page).to have_no_content content
      end
    else
      expect(page).to have_no_content content
    end
  end

  def the_field_should_contain field_name, value
    field = find_field(field_name)
    expect(field.value).to eq value
  end

  # JavaScript alerts and prompts.
  def i_will_confirm_on_the_next_step
    evaluate_script "window.alert = function(msg) { return true; }"
    evaluate_script "window.confirm = function(msg) { return true; }"
    evaluate_script "window.prompt = function(msg) { return true; }"
  rescue Capybara::NotSupportedByDriverError
    nil
  end

  # Activity feed.
  def there_should_be_an_activity did_something, edit_summary: nil
    activity = Activity.last

    # HACK: Name ignored (it's fine) because it's easier to read expectations that are full sentences.
    # TODO: Probably make it more obvious that it's not checked.
    did_something = did_something.delete_prefix('Archibald ')
    normalized_did_something = ActionController::Base.helpers.strip_tags(activity.decorate.did_something).squish

    expect(normalized_did_something).to match did_something
    expect(activity.edit_summary).to eq edit_summary
  end

  # Record pickers.
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

  # Misc.
  def i_select_the_reference_tab tab_css_selector
    find(tab_css_selector, visible: false).click
  end

  def wait_for_taxt_editors_to_load
    if javascript_driver?
      find('body[data-test-taxt-editors-loaded="true"]')
    else
      $stdout.puts "skipping wait_for_taxt_editors_to_load because spec is not using javascript".red
    end
  end

  # TODO: See if we can replace this and `wait_for_taxt_editors_to_load` with something general.
  def wait_for_atwho_to_load
    if javascript_driver?
      find('body[data-test-atwho-loaded="true"]')
    else
      $stdout.puts "skipping wait_for_atwho_to_load because spec is not using javascript".red
    end
  end

  def these_settings yaml_string
    hsh = YAML.safe_load(yaml_string)
    Settings.merge!(hsh)
  end

  def javascript_driver?
    Capybara.current_driver == Capybara.javascript_driver
  end

  private

    def set_record_picker record_id, css_selector
      find(css_selector).set(record_id)
    end
end
