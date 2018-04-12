Zepto ($)->

  motionDiff = (ref)->
    ref = ref || 0
    sameStyle = 'rounded diff-same'
    diffStyle = 'rounded diff-unsame'
    matrix = $('.motion:not(.unified)').map -> [$(this).children('.comparable')]
    matrix.each (i, e)->
      $(e).each (ii, ee)->
        ez = $(ee)
        if i is ref
          ez.removeClass "#{sameStyle} #{diffStyle}"
        else if ez.data('value') == $(matrix[ref][ii]).data('value')
          ez.removeClass(diffStyle).addClass(sameStyle)
        else
          ez.removeClass(sameStyle).addClass(diffStyle)

  # unification toggler
  $('.unified').hide()
  $('.toggle-unified').addClass('btn-primary').text('Show')
  .on 'click', ->
    # nextUntil equivalent
    n = $(this).closest('.motion').next()
    while n.is('.unified')
      n.toggle()
      n = n.next()
      break if n.length is 0

    $(this).toggleClass('btn-primary').text if $(this).hasClass('btn-primary') then 'Show' else 'Hide'

  # align column heights
  $('.variable-comment').height (i, o)->
    Math.max.apply null, $('.motion .variable-comment').map -> $(this).height()
  $('#caption .variable-others').height (i, o)->
    Math.max.apply null, $('.motion').map ->
      rows = $(this).children('.variable-others')
      return 0 if rows.length is 0
      bottom = rows.eq(-1).offset()
      bottom.top + bottom.height - rows.eq(0).offset().top

  # diff coloring
  motionDiff()
  