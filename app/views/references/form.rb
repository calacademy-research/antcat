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
        table do
          colgroup do
            col :width => '*'
            col :width => '100px'
          end
          tr do 
            td(:class => 'authors') {f.text_field :authors}
            td(:class => 'year')    {f.text_field :year}
          end
          tr {td(:colspan => 2) {f.text_field :title}}
          tr {td(:colspan => 3) {f.text_field :citation}}
          tr {td(:colspan => 3) {f.text_field :public_notes}}
          tr {td(:colspan => 3) {f.text_field :editor_notes}}
          tr {td(:colspan => 3) {f.text_field :taxonomic_notes}}
          tr do 
            td { table(:class => 'small_fields') { tr {
              td(:class => 'cite_code') {f.text_field :cite_code}
              td(:class => 'possess')   {f.text_field :possess}
              td(:class => 'date')      {f.text_field :date}
            }}}
          end
          tr do
            td(:colspan => 3) do
              span :id => 'buttons' do
                f.submit 'OK', :name => 'commit'
                button 'Cancel', :class => 'cancel'
                button 'Delete', :class => 'delete'
              end
            end
          end
        end
      end
    end
  end
end
