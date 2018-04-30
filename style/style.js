var sections = new Array();

$(document).ready(function(){
  
  $('#levelselectlist').hide();
  $('#levelselecttab').toggle(
    function(e) {
      $('#levelselectlist').slideDown(250);
    },
    function(e) {
      $('#levelselectlist').slideUp(250);
    });
  
  $('#styleswitcher').css('display', 'block');
  
    $('#map').hover(
      function(e) {
        $('.mapoverlay').addClass('mapoverlayactive');
      },
      function(e) {
        $('.mapoverlay').removeClass('mapoverlayactive');
      });
    
    $('.monster_indicator').hide();
    $('.ladder_indicator').hide();
    $('.tele_indicator').hide();
    $('.ladder_dest_indicator').hide();
    $('.door_indicator').hide();
    $('.door_secret_indicator').hide();
    $('.door_trigger_indicator').hide();
    $('.other_trigger_indicator').hide();
    $('.save_indicator').hide();
    $('.corpse_indicator').hide();
    $('.item_indicator').hide();
    
    makeSection('item');
    makeSection('corpse');
    makeSection('monster');
    makeSection('trigger');
    makeSection('tele');
    makeSection('ladder');
    showSection(sections[0]);
    
    var i;  
    for (i = 0; i < 17; i++)
    {
      makeHover('monster', i);
      makeFancybox('monster', i);
    }
    makeHoverAll('monster');
    
    for (i = 0; i < 15; i++)
      makeHover('door', i);
    makeHoverAll('door');
  
    for (i = 0; i < 20; i++)
      makeHover('door_secret', i);
    makeHoverAll('door_secret');
    
    for (i = 0; i < 40; i++)
      makeHover('other_trigger', i);
    makeHoverAll('other_trigger');
    
    for (i = 0; i < 256; i++)
      makeHover('door_trigger', i);
    makeHoverAll('door_trigger');
    
    for (i = 0; i < 20; i++)
      makeHover('save', i);
    makeHoverAll('save');
    
    for (i = 0; i < 20; i++)
      makeHover('ladder', i);
    makeHoverAll('ladder');
    makeHoverAll('tele');
    
    for (i = 0; i < 29; i++)
      makeHover('corpse', i);
    makeHoverAll('corpse');
    
    for (i = 0; i < 71; i++)
    {
      makeHover('item', i);
      makeFancybox('item', i);
    }
    makeHoverAll('item');
    
    makeHoverAll('trigger');

});

function makeFancybox(type, idx)
{
  $('li.' + type + '_' + idx).fancybox({
    'hideOnOverlayClick' : true,
    'overlayShow' : true,
    'overlayOpacity' : 0.0,
    'padding' : 0,
    'margin' : 0,
    'showCloseButton' : false,
    'transitionIn' : 'fade',
    'transitionOut' : 'fade',
    'speedIn' : 150,
    'speedOut' : 150,
    'titleShow' : false,
    'type' : 'inline',
    'href' : '#' + type + 'desc_' + idx });
  $('#' + type + 'desc_' + idx).click(
    function(e) {
      $.fancybox.close();
    });
}

function makeHover(type, idx)
{
  $('.' + type + '_' + idx).hover(makeShow(type, idx), makeHide(type, idx));
}

function makeShow(type, idx)
{
  return function(e) {
    $('.' + type + '_indicator_' + idx).show();
  };
}
function makeHide(type, idx)
{
  return function(e) {
    $('.' + type + '_indicator_' + idx).hide();
  };
}

function makeHoverAll(type)
{
  $('.' + type + '_all').hover(
    function(e) {
      $('.' + type + '_indicator').show();
    },
    function(e) {
      $('.' + type + '_indicator').hide();
    });
}

function showSection(type)
{
  $('DIV#summary H3').each(function(idx) {
    var th = $(this);
    if (th.hasClass(type + '_all'))
      th.addClass('active');
    else
      th.removeClass('active');
  });
  
  $('DIV#summary UL').each(function(idx) {
    var th = $(this);
    if (th.hasClass(type + '_summary'))
      th.addClass('active');
    else
      th.removeClass('active');
  });
}

function makeSection(type)
{
  var he = $('DIV#summary H3.' + type + '_all');
  var le = $('DIV#summary UL.' + type + '_summary');
  if ((he.length > 0) && (le.length > 0))
  {
    sections[sections.length] = type;
    he.click(function(e) { showSection(type); });
  }
}
