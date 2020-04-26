# frozen_string_literal: true

module ReferenceSelectHelper
  def reference_select_tag reference_attribute_name, reference_id
    reference = Reference.find_by(id: reference_id)
    reference_id = reference&.id

    select_tag reference_attribute_name,
      options_for_select([reference_id].compact, reference_id),
      class: 'select2-autocomplete', data: reference_data_attributes(reference)
  end

  private

    def reference_data_attributes reference
      for_reference = if reference
                        {
                          title: reference.title,
                          author: reference.author_names_string_with_suffix,
                          year: reference.citation_year_with_stated_year
                        }
                      end

      { reference_select: true }.merge(for_reference || {})
    end

    module FormBuilderAdditions
      include ActionView::Helpers::FormOptionsHelper
      include ReferenceSelectHelper

      def reference_select reference_attribute_name
        reference = object.public_send reference_attribute_name
        reference_id = reference&.id

        select "#{reference_attribute_name}_id".to_sym,
          options_for_select([reference_id].compact, reference_id),
          { include_blank: '(none)' },
          class: 'select2-autocomplete', data: reference_data_attributes(reference)
      end
    end
end

ActionView::Helpers::FormBuilder.include ReferenceSelectHelper::FormBuilderAdditions
