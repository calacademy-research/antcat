$(function() {
  $('#q_help').qtip({
    content: "Enter search words, e.g. 'Bolton 2011'. References matching all words will be displayed.",
    show: 'mouseover',
    hide: 'mouseout',
    position: {
      adjust: {y: -7},
      corner: {target: 'topLeft', tooltip: 'bottomRight'}
    }
  });
  $('#match_threshold_help').qtip({
    content: "Only show Bolton references whose best matches are at or below this value. Leave blank to show all.",
    show: 'mouseover',
    hide: 'mouseout',
    position: {
      adjust: {y: -7},
      corner: {target: 'topLeft', tooltip: 'bottomRight'}
    }
  });
  $('#match_type_help').qtip({
    content: "'Auto' matches are those for which the score was >= 0.8. 'None' shows references without matches. Leaving all blank finds all.",
    show: 'mouseover',
    hide: 'mouseout',
    position: {
      adjust: {y: -7},
      corner: {target: 'topLeft', tooltip: 'bottomRight'}
    }
  });
})
