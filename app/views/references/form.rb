class Views::References::Form < Erector::Widget
  needs :reference => nil, :class => 'reference_form'

  def content
    @reference ||= Reference.new
    unless @reference.new_record?
      form_options = {:url => reference_path(@reference)}
    else
      form_options = {:url => references_path, :action => :create}
    end

    div :class => @class do
      form_for([:reference, @reference], form_options) do |f|
        table :style => 'width:100%' do
          col :width => '*'
          col :width => '100px'
          tr do 
            td(:style => 'padding-bottom: 3px; padding-right: 8px') {f.text_field :authors, :style => 'width: 100%'}
            td(:style => 'padding-bottom: 3px;') {f.text_field :year, :style => 'width: 100%'}
          end
          tr {td(:style => 'padding-bottom: 3px', :colspan => 2) {f.text_field :title, :style => 'width: 100%'}}
          tr {td(:style => 'padding-bottom: 3px', :colspan => 3) {f.text_field :citation, :style => 'width: 100%'}}
          tr {td(:style => 'padding-bottom: 3px', :colspan => 3) {f.text_field :public_notes, :style => 'width: 100%'}}
          tr {td(:style => 'padding-bottom: 3px', :colspan => 3) {f.text_field :editor_notes, :style => 'width: 100%'}}
          tr {td(:style => 'padding-bottom: 3px', :colspan => 3) {f.text_field :taxonomic_notes, :style => 'width: 100%'}}
          tr do 
            td { table { tr {
              td(:style => 'padding-bottom: 3px; padding-right: 8px') {f.text_field :cite_code, :style => 'width: 70px'}
              td(:style => 'padding-bottom: 3px;')                    {f.text_field :possess, :style => 'width: 100px'}
              td(:style => 'padding-bottom: 3px; padding-left: 8px')  {f.text_field :date, :style => 'width: 75px'}
            } } }
          end
          tr do
            td(:colspan => 3) do
              span :id => 'buttons' do
                f.submit 'OK', :name => 'commit'
                button 'Cancel', :class => 'cancel'
                button 'Delete', :class => 'cancel'
              end
            end
          end
        end
      end
    end
  end
end
