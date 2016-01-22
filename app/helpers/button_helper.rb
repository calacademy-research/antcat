module ButtonHelper
  # "Parameters" for the three below items end up as literal parameters for the html input object.
  # e.g.:  button 'Delete', 'delete_button', {'data-delete-location' => "/taxa/#{@taxon.id}/delete",'data-taxon-id' => "#{@taxon.id}"}
  # Yields: "<input data-delete-location="/taxa/449381/delete" data-taxon-id="449381" ...

  def button label, id = nil, parameters = {}, extra_classes = []
    make_button label, id, 'button', parameters, extra_classes
  end

  private
    def make_button label, id, type, parameters = {}, extra_classes = []
      parameters = parameters.dup
      parameters[:class] = get_css_classes parameters, extra_classes
      parameters[:id] = id || (label + '_button').downcase
      parameters[:type] = type
      parameters[:value] = label
      content_tag 'input', '', parameters
    end

    def get_css_classes parameters, extra_classes = []
      classes = (parameters[:class] || '').split ' '
      classes.concat extra_classes
      classes.sort.join ' '
    end
end
