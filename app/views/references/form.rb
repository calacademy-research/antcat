class Views::References::Form < Erector::Widget

  needs :f, :submit_text => "Update"

  def content
    @f.error_messages

    table(:class => 'reference-fields') do
      tr do
        td
        td {span "Use vertical bars or asterisks around italicized text", :class => 'instructions'}
      end

      tr do
        td {@f.label :authors}
        td {@f.text_field :authors, :class => "wide"}
      end
      tr do
        td {@f.label :year}
        td {@f.text_field :year, :class => "small"}
      end
      tr do
        td {@f.label :title}
        td {@f.text_field :title, :class => "wide"}
      end
      tr do
        td {@f.label :citation}
        td {@f.text_area :citation, :rows => 3, :class => "wide"}
      end
      tr do
        td {@f.label :notes}
        td {@f.text_area :notes, :rows => 2, :class => 'wide'}
      end
      tr do
        td {@f.label :cite_code}
        td {@f.text_field :cite_code, :class => 'small'}
      end
      tr do
        td {@f.label :possess}
        td {@f.text_field :possess, :class => 'small'}
      end
      tr do
        td {@f.label :date}
        td {@f.text_field :date, :class => 'small'}
      end
      tr do
        td
        td {@f.submit @submit_text}
      end
      
    end
  end

end
