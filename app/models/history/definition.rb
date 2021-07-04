# frozen_string_literal: true

module History
  class Definition
    def self.from_type type_name
      new(History::Definitions::TYPE_DEFINITIONS[type_name])
    end

    def self.all
      History::Definitions::TYPES.map { |type_name| from_type type_name }
    end

    def initialize type_attributes
      @type_attributes = type_attributes
    end

    def groupable?
      type_attributes[:group_key].present?
    end

    def type_name
      type_attributes.fetch(:type_name)
    end

    def type_label
      type_attributes.fetch(:type_label)
    end

    def group_order
      type_attributes.fetch(:group_order)
    end

    def group_key history_item, template_name
      @_group_key_cache ||= {}

      @_group_key_cache[template_name] ||= begin
        template = type_attributes[:templates].fetch(template_name)

        if (key = template[:group_key] || type_attributes.fetch(:group_key, nil))
          key.call(history_item)
        else
          history_item.id
        end
      end
    end

    def render_template template_name, history_item, vars = {}
      template = type_attributes[:templates].fetch(template_name)
      raise "missing template '#{template_name}'" unless template

      template_vars = template[:vars].call(history_item).symbolize_keys if template[:vars]
      template.fetch(:content) % (template_vars || {}).merge(vars)
    end

    def groupable_template_content
      @_groupable_template_content ||= type_attributes.fetch(:groupable_template_content, nil)
    end

    def groupable_template_vars history_item
      return {} unless (vars = type_attributes[:groupable_template_vars])
      vars.call(history_item).symbolize_keys
    end

    def subtypes
      type_attributes[:subtypes]
    end

    def validates_presence_of
      type_attributes.fetch(:validates_presence_of)
    end

    def optional_attributes
      @_optional_attributes ||= type_attributes[:optional_attributes] || []
    end

    private

      attr_reader :type_attributes
  end
end
