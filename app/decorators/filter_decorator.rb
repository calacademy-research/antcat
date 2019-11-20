class FilterDecorator
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::FormTagHelper

  def initialize filter, params
    @column, @values = filter
    @params = params
  end

  def render_html
    public_send values[:tag], column, *args
  end

  private

    attr_reader :column, :values, :params

    def args
      case values[:tag]
      when :select_tag
        [
          options_for_select(values[:options].call, params[column]),
          { prompt: values[:prompt] || column.to_s.humanize }
        ]
      when :number_field_tag
        [
          params[column],
          { placeholder: values[:placeholder] || column.to_s.humanize }
        ]
      else
        raise "#{tag} is not supported"
      end
    end
end
