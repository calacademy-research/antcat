$(function() {
  $('.help_icon').qtip({
    content: "Enter search words. References matching all words will be displayed.",
    show: 'mouseover',
    hide: 'mouseout',
    position: {
      adjust: {y: -7},
      corner: {target: 'topLeft', tooltip: 'bottomRight'}
    }
  })
})
