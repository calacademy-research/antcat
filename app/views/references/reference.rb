class Views::References::Reference < Erector::Widget
  needs :reference

  def content
    div :id => "reference_display_#{@reference.id}", :class => 'reference_display' do
      a :href => "#", :class => 'reference_link' do
        rawtext format_reference(@reference)
        rawtext ' '
        p(:class => 'notes')          {rawtext italicize(@reference.public_notes)}
        p(:class => 'private notes')  {rawtext italicize(@reference.private_notes)}
        p(:class => 'notes')          {rawtext italicize(@reference.taxonomic_notes)}
      end
    end

    div :id => "reference_form_#{@reference.id}", :class => 'reference_form' do
      form_for([:reference, @reference], :url => reference_path(@reference)) do |f|
        table :style => 'width:100%' do
          tr do 
            td {f.text_field :authors, :style => 'width: 200px'}
            td {f.text_field :year, :style => 'width: 100px'}
            td {f.text_field :citation, :style => 'width: 400px'}
          end
          tr {td(:colspan => 3) {f.text_field :public_notes, :style => 'width: 100%'}}
          tr {td(:colspan => 3) {f.text_field :private_notes, :style => 'width: 100%'}}
          tr {td(:colspan => 3) {f.text_field :taxonomic_notes, :style => 'width: 100%'}}
          tr do
            td(:colspan => 3) do
              f.submit 'OK', :name => 'commit'
              button 'Cancel', :class => 'cancel'
            end
          end
        end
      end
    end

    widget Views::Coins.new :reference => @reference

  end

  def format_reference reference
    "#{italicize(reference.authors)} #{reference.year}. #{italicize(reference.title)} #{italicize(reference.citation)}"
  end

  def italicize s
    return unless s
    s = s.html_escape
    s = s.gsub /\*(.*?)\*/, '<span class=taxon>\1</span>'
    s = s.gsub /\|(.*?)\|/, '<span class=taxon>\1</span>'
  end

end
