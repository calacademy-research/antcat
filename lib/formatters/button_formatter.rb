# coding: UTF-8
module Formatters::ButtonFormatter
  include ActionView::Helpers::TagHelper

  def button label, id = nil, parameters = {}
    parameters = parameters.dup
    classes = (parameters[:class] || '').split ' '
    jquery_classes = %w{ui-button ui-corner-all ui-priority-primary}
    classes.concat jquery_classes
    parameters[:class] = classes.sort.join ' '

    parameters[:id] = id || (label + '_button').downcase
    parameters[:type] = 'button'
    parameters[:value] = label
    content_tag 'input', '', parameters
  end

  def submit_button label, id = nil, parameters = {}
    parameters = parameters.dup
    parameters[:class] = set_jquery_css_classes parameters
    parameters[:id] = id || (label + '_button').downcase
    parameters[:type] = 'submit'
    parameters[:value] = label
    content_tag 'input', '', parameters
  end

  def cancel_button label = 'Cancel', id = nil, parameters = {}
    parameters = parameters.dup

    classes = (parameters[:class] || '').split ' '
    jquery_classes = %w{ui-button ui-corner-all ui-priority-secondary}
    classes.concat jquery_classes
    classes << 'cancel'
    parameters[:class] = classes.sort.join ' '

    parameters[:id] = id || (label + '_button').downcase
    parameters[:type] = 'button'
    parameters[:value] = label
    content_tag 'input', '', parameters
  end

  def set_jquery_css_classes parameters
    classes = (parameters[:class] || '').split ' '
    jquery_classes = %w{ui-button ui-corner-all}
    classes.concat jquery_classes
    is_secondary = parameters.delete :secondary
    if is_secondary
      classes << 'ui-priority-secondary'
    else
      classes << 'ui-priority-primary'
    end
    classes.sort.join ' '
  end

end
