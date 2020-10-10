# frozen_string_literal: true

module ProtonymSelectHelper
  def protonym_select_tag protonym_attribute_name, protonym_id
    protonym = Protonym.find_by(id: protonym_id)
    protonym_id = protonym&.id

    select_tag protonym_attribute_name,
      options_for_select([protonym_id].compact, protonym_id),
      class: 'select2-autocomplete', data: protonym_data_attributes(protonym)
  end

  private

    def protonym_data_attributes protonym
      for_protonym = if protonym&.persisted?
                       {
                         name_with_fossil: protonym.decorate.name_with_fossil,
                         author_citation: protonym.author_citation
                       }
                     end

      { protonym_select: true }.merge(for_protonym || {})
    end

    module FormBuilderAdditions
      include ActionView::Helpers::FormOptionsHelper
      include ProtonymSelectHelper

      def protonym_select protonym_attribute_name
        protonym = object.public_send protonym_attribute_name
        protonym_id = protonym&.id

        select "#{protonym_attribute_name}_id".to_sym,
          options_for_select([protonym_id].compact, protonym_id),
          { include_blank: '(none)' },
          class: 'select2-autocomplete', data: protonym_data_attributes(protonym)
      end
    end
end

ActionView::Helpers::FormBuilder.include ProtonymSelectHelper::FormBuilderAdditions
