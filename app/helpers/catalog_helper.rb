module CatalogHelper

  def taxon_browser_link taxon
    classes = css_classes_for_rank(taxon)
    classes << css_classes_for_status(taxon)
    link_to taxon_label(taxon), catalog_path(taxon), class: classes
  end

  def panel_header selected
    if selected.is_a? Taxon
      "#{selected.rank.capitalize}: #{taxon_breadcrumb_label selected}"
    else
      selected[:title_for_panel]
    end.html_safe
  end

  def all_genera_link selected
    extra_panel_link selected, "All genera", "all_genera_in_#{selected.rank}"
  end

  def incertae_sedis_link selected
    return if selected.genera_incertae_sedis_in.empty?
    extra_panel_link selected, "Incertae sedis", "incertae_sedis_in_#{selected.rank}"
  end

  def toggle_valid_only_link
    showing = session[:show_valid_only]
    label = showing ? "show invalid" : "show valid only"
    link_to label, catalog_options_path(valid_only: showing)
  end

  def taxon_label_span taxon
    content_tag :span, class: css_classes_for_rank(taxon) do
      taxon_label(taxon).html_safe
    end
  end

  def taxon_label taxon
    taxon.name.epithet_with_fossil_html taxon.fossil?
  end

  def protonym_label protonym
    protonym.name.protonym_with_fossil_html protonym.fossil
  end

  def css_classes_for_rank taxon
    [taxon.type.downcase, 'taxon', 'name'].sort
  end

  def open_panel? selected, self_and_parents
    return true if disable_taxon_browser?

    cookies[:close_inactive_panels] == "false" || # open if asked to do so
    is_last_panel?(selected, self_and_parents) ||
    selected.is_a?(Genus)        # always open genus panel
  end

  def show_taxon_browser?
    return true if disable_taxon_browser?

    # "Keep open" means "continue to be open", not "always open".
    # If the browser is hidden, it stays hidden. Like this:
    #
    #                  keep_open_on  keep_open_off
    # browser_hidden       HIDE          HIDE
    # browser_visible      SHOW          HIDE
    cookies[:show_browser] != "false" &&
    cookies[:keep_taxon_browser_open] != "false"
  end

  # For disabling the taxon browser by default in test env.
  # Hiding it and closing its panels would break loads of tests.
  def disable_taxon_browser?
    if Rails.env.test?
      return true unless $taxon_browser_test_hack
    end
  end

  private
    # HACK -ish
    def is_last_panel? selected, self_and_parents
      self_and_parents.last == selected ||  # last taxon in panel chain

      # hack for "incertae sedis"/"all genera", which always is last
      !selected.is_a?(Taxon) ||

      selected.nil? ||           # no selected -> must be last
      selected.is_a?(Species)    # species is always last
    end

    def extra_panel_link selected, label, param
      css_class = if params[:display] == param
                    "upcase selected"
                  else
                    "upcase white-label"
                  end
      content_tag :li do
        content_tag :span, class: css_class do
          link_to label, catalog_path(selected, display: param)
        end
      end
    end

    def css_classes_for_status taxon
      css_classes = []
      css_classes << taxon.status.downcase.gsub(/ /, '_')
      css_classes << 'nomen_nudum' if taxon.nomen_nudum?
      css_classes << 'collective_group_name' if taxon.collective_group_name?
      css_classes
    end

end
