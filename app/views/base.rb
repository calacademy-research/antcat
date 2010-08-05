class Views::Base < Erector::Widgets::Page

  def head_content
    super
    css '/stylesheets/application.css'
    css '/stylesheets/jquery-ui/ui-lightness/jquery-ui-1.8.2.custom.css'
    javascript_include_tag '/javascripts/ext/jquery-1.4.2.js'
    javascript_include_tag '/javascripts/ext/jquery-ui-1.8.2.custom.min.js'
    jquery '$(":input:visible:enabled:first").focus();'
  end

  def page_title
    "ANTBIB"
  end

  def body_content
    div :id => 'container' do

      div :class => 'heading' do
        div :style => 'float:left' do
          a(:href => references_path) { h1 'ANTBIB' }
        end
        div :style => 'float:left' do
          h2 do
            text 'A Bibliography of Ant Systematics'
          end
        end
        div(:style => 'float:right') do
          h3 'by Philip S. Ward, et al.'
        end
      end

      div :style => 'clear:both'

      p :id => 'flash' do
        text flash[:notice]
      end

      hr
      container_content
      hr
      table(:style => 'width: 100%') do
        tr do
          td(:width => '25%', :align => :left) { img :style => "height:44px", :src => '/images/rails.png' }
          td(:width => '25%', :align => :center) { img :style => "height:44px", :src => '/images/nsf1.gif' }
          td(:width => '25%', :align => :center) { img :src => '/images/calacademy.gif' }
          td(:width => '25%', :align => :right) { img :src => '/images/zotero_logo_tiny.png' }

        end
      end
    end
  end

  def container_content

  end

end
