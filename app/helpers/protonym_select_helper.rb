module ProtonymSelectHelper
  private

    def protonym_data_attributes protonym
      for_protonym = if protonym.persisted?
                       {
                         name_with_fossil: protonym.decorate.format_name,
                         author_citation: protonym.authorship.reference.keey_without_letters_in_year
                       }
                     end

      { protonym_select: true }.merge(for_protonym || {})
    end

    module FormBuilderAdditions
      include ActionView::Helpers::FormOptionsHelper
      include ProtonymSelectHelper

      def protonym_select protonym_attribute_name
        protonym = object.send protonym_attribute_name
        protonym_id = protonym&.id

        select "#{protonym_attribute_name}_id".to_sym,
          options_for_select([protonym_id].compact, protonym_id),
          { include_blank: '(none)' },
          class: 'select2-autocomplete', data: protonym_data_attributes(protonym)
      end
    end
end

ActionView::Helpers::FormBuilder.send(:include, ProtonymSelectHelper::FormBuilderAdditions)
