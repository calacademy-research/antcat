class Views::References::Form < Erector::Widget

  needs :f, :submit_text => "Update"

  def content
    @f.error_messages

    p do
      @f.label :authors
      br
      @f.text_area :authors
    end
    p do
      @f.label :year
     br
      @f.text_field :year
    end
    p do
      @f.label :title
      br
      @f.text_field :title
    end
    p do
      @f.label :citation
      br
      @f.text_area :citation
    end
    p do
      @f.label :notes
      br
      @f.text_area :notes
    end
    p do
      @f.label :possess
      br
      @f.text_field :possess
    end
    p do
      @f.label :date
      br
      @f.text_field :date
    end
    p do
      @f.label :excel_file_name
      br
      @f.text_field :excel_file_name
    end
    p do
      @f.label :cite_code
      br
      @f.text_field :cite_code
    end
    p do
      @f.submit @submit_text
    end
  end

end
