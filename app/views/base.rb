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
      a(:href => references_path) {h3 'ANTBIB'}

      p :id => 'flash' do
        text flash[:notice]
      end

      hr
      container_content
      hr
      table(:style => 'width: 100%') do
        tr do
          td(:style => 'width:358px') {img :style => "height:44px", :src => '/images/rails.png'}
          td(:style => 'width:412px') {img :src => '/images/calacademy.gif'}
          td() {img :src => '/images/zotero_logo_tiny.png'}

        end
      end
    end
  end

  def container_content
    
  end
end
