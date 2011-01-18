$(function() {
  send_options_when_taxon_clicked()
})

function send_options_when_taxon_clicked() {
  $('.taxon a').click(function(){
    this.href += '&show_tribes=' + $('#show_tribes')[0].checked
  })
}
