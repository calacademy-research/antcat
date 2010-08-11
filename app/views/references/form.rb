class Views::References::Form < Erector::Widget

  needs :f, :submit_text => "Update"

  def content
    jquery '$("#reference_journal_title").autocomplete({source: "/journals", minLength: 3});'

    @f.error_messages

    table(:class => 'reference-fields') do
      tr do
        td
        td { span "Use vertical bars or asterisks around italicized text", :class => 'instructions' }
      end

      tr do
        td { @f.label :authors }
        td { @f.text_field :authors, :class => "wide" }
      end
      tr do
        td { @f.label :year }
        td { @f.text_field :year, :class => "small" }
      end
      tr do
        td { @f.label :numeric_year }
        td { @f.text_field :numeric_year, :class => "small" }
      end
      tr do
        td { @f.label :title }
        td { @f.text_field :title, :class => "wide" }
      end
    end

    hr

    table(:class => 'reference-fields') do
      tr do
        td
        td(:style => 'font-style: italic') {text "If you change the citation, change the individual fields below (and vice versa)"}
      end
      tr do
        td { @f.label :citation }
        td { @f.text_area :citation, :rows => 3, :class => "wide" }
      end
      tr do
        td { @f.label :kind }
        td { @f.select :kind, ['book', 'journal', 'unknown'] }
      end

      tr do
        td
        td(:style => 'font-style: italic') {text "Journal"}
      end
      tr do
        td { @f.label :journal_title }
        td { @f.text_field :journal_title, :class => "wide" }
      end
      tr do
        td { @f.label :series }
        td { @f.text_field :series, :class => "small" }
      end
      tr do
        td { @f.label :volume }
        td { @f.text_field :volume, :class => "small" }
      end
      tr do
        td { @f.label :issue }
        td { @f.text_field :issue, :class => "small" }
      end
      tr do
        td { @f.label :start_page }
        td { @f.text_field :start_page, :class => "small" }
      end
      tr do
        td { @f.label :end_page }
        td { @f.text_field :end_page, :class => "small" }
      end

      tr do
        td
        td(:style => 'font-style: italic') {text "Book"}
      end
      tr do
        td { @f.label :place }
        td { @f.text_field :place, :class => "wide" }
      end
      tr do
        td { @f.label :publisher }
        td { @f.text_field :publisher, :class => "wide" }
      end
      tr do
        td { @f.label :pagination }
        td { @f.text_field :pagination, :class => "small" }
      end
    end

    hr

    table(:class => 'reference-fields') do
      tr do
        td { @f.label :public_notes }
        td { @f.text_area :public_notes, :rows => 2, :class => 'wide' }
      end
      tr do
        td { @f.label :editor_notes }
        td { @f.text_area :editor_notes, :rows => 2, :class => 'wide' }
      end
      tr do
        td { @f.label :taxonomic_notes }
        td { @f.text_area :taxonomic_notes, :rows => 2, :class => 'wide' }
      end
      tr do
        td { @f.label :cite_code }
        td { @f.text_field :cite_code, :class => 'small' }
      end
      tr do
        td { @f.label :possess }
        td { @f.text_field :possess, :class => 'small' }
      end
      tr do
        td { @f.label :date }
        td { @f.text_field :date, :class => 'small' }
      end
      tr do
        td
        td do
          @f.submit @submit_text, :name => 'commit'
          @f.submit 'Cancel', :name => 'commit', :value => 'Cancel'
        end
      end

    end
  end

end
