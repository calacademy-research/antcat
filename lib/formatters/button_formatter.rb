# coding: UTF-8
module Formatters::ButtonFormatter
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper

  def button label, id = nil, parameters = {}
    make_button label, id, 'button', parameters
  end

  def submit_button label, id = nil, parameters = {}
    make_button label, id, 'submit', parameters, ['submit']
  end

  def cancel_button label = 'Cancel', id = nil, parameters = {}
    parameters[:secondary] = true
    make_button label, id, 'button', parameters, ['cancel']
  end

  def button_to_path label, path, parameters = {}
    string = button_to label, path, parameters
    classes = get_css_classes parameters
    string.gsub! /<input /, "<input class=\"#{classes}\" "
    string.html_safe
  end

  ###
  def make_button label, id, type, parameters = {}, extra_classes = []
    parameters = parameters.dup
    parameters[:class] = get_css_classes parameters, extra_classes
    parameters[:id] = id || (label + '_button').downcase
    parameters[:type] = type
    parameters[:value] = label
    content_tag 'input', '', parameters
  end

  def jquery_css_classes
    %w{ui-button ui-corner-all}
  end

  def get_css_classes parameters, extra_classes = []
    classes = (parameters[:class] || '').split ' '
    classes.concat jquery_css_classes
    if parameters.delete :secondary
      classes << 'ui-priority-secondary'
    else
      classes << 'ui-priority-primary'
    end
    classes.concat extra_classes
    classes.sort.join ' '
  end

end
