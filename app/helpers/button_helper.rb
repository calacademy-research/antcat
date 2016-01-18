module ButtonHelper
  # "Parameters" for the three below items end up as literal parameters for the html input object.
  # e.g.:  button 'Delete', 'delete_button', {'data-delete-location' => "/taxa/#{@taxon.id}/delete",'data-taxon-id' => "#{@taxon.id}"}
  # Yields: "<input data-delete-location="/taxa/449381/delete" data-taxon-id="449381" class="ui-button  ...

  def button label, id = nil, parameters = {}, extra_classes = []
    make_button label, id, 'button', parameters, extra_classes
  end

  def submit_button label, id = nil, parameters = {}
    make_button label, id, 'submit', parameters, ['submit']
  end

  def cancel_button label = 'Cancel', id = nil, parameters = {}
    parameters[:secondary] = true
    make_button label, id, 'button', parameters, ['cancel', 'btn-cancel']
  end

  def button_to_path label, path, parameters = {}
    string = button_to label, path, parameters
    classes = get_css_classes parameters
    string.gsub! /<input /, "<input class=\"#{classes}\" "
    string.html_safe
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
      classes.concat jquery_css_classes

      classes << if parameters.delete :secondary
                   'ui-priority-secondary'
                 else
                   'ui-priority-primary'
                 end
      classes.concat extra_classes
      classes.sort.join ' '
    end

    def jquery_css_classes
      %w{ui-button ui-corner-all}
    end
end
