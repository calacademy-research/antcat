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
    # always open in test, unless we're testing the taxon browser
    if Rails.env.test?
      return true unless $taxon_browser_test_hack
    end

    is_last_panel?(selected, self_and_parents) ||
    selected.is_a?(Genus)        # always open genus panel
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
