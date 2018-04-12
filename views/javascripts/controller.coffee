Zepto ($)->

  motionDiff = (ref)->
    ref = ref || 0
    sameStyle = 'rounded bg-success'
    diffStyle = 'rounded bg-error'
    matrix = $('.motion:not(unified)').map -> [$(this).children('.comparable')]
    matrix.each (i, e)->
      $(e).each (ii, ee)->
        ez = $(ee)
        if i == ref
          ez.removeClass "#{sameStyle} #{diffStyle}"
        else if ez.data('value') == $(matrix[ref][ii]).data('value')
          ez.removeClass(diffStyle).addClass(sameStyle)
        else
          ez.removeClass(sameStyle).addClass(diffStyle)

  # unification toggler
  $('.unified').hide()
  $('.toggle-unified').addClass('btn-primary').text('Show')
  .on 'click', ->
    $(this).closest('.motion')
    $(this).toggleClass('btn-primary').text if $(this).hasClass('btn-primary') then 'Show' else 'Hide'

  # align column heights
  $('.variable-comment').height (i, o)->
    Math.max.apply null, $('.motion .variable-comment').map -> $(this).height()
  $('#caption .variable-others').height (i, o)->
    Math.max.apply null, $('.motion').map ->
      $(this).children('.variable-others').reduce (m, e)-> m + $(e).height(),
      0

  # diff coloring
  motionDiff()
  