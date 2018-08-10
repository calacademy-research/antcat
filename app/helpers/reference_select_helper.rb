module ReferenceSelectHelper
  private

    def reference_data_attributes reference
      for_reference = if reference
                        {
                          title: reference.title,
                          author: reference.author_names_string,
                          year: reference.citation_year
                        }
                      end

      { reference_select: true }.merge(for_reference || {})
    end

    module FormBuilderAdditions
      include ActionView::Helpers::FormOptionsHelper
      include ReferenceSelectHelper

      def reference_select reference_attribute_name
        reference = object.send reference_attribute_name
        reference_id = reference.try(:id)

        select "#{reference_attribute_name}_id".to_sym,
          options_for_select([reference_id].compact, reference_id),
          { include_blank: '(none)' },
          class: 'select2-autocomplete', data: reference_data_attributes(reference)
      end
    end
end

ActionView::Helpers::FormBuilder.send(:include, ReferenceSelectHelper::FormBuilderAdditions)
