Zepto ($)->

  motionDiff = (ref)->
    sameStyle = 'rounded diff-same'
    diffStyle = 'rounded diff-unsame'
    targets = $('.motion:not(.unified):not(.editor)')
    names = targets.map -> $(this).attr('id')
    matrix = targets.map -> [$(this).children('.comparable')] # flatten-proof
    pivot = Math.max names.indexOf(ref), 0 # 0 if not found
    matrix.each (i, e)->
      $(e).each (ii, ee)->
        ez = $(ee)
        if i == pivot
          ez.removeClass "#{sameStyle} #{diffStyle}"
        else if ez.data('value') == $(matrix[pivot][ii]).data('value')
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

  # editing mode
  colors = 'bg-dark bg-success bg-error'
  $('#push').on 'click', ->
    [doc, char] = [$('#inedition').data('edit'), $('#current').data('code')]
    entry = $(this).closest('.column')
    fields = $('.mfield').reduce (m, field)->
        m[$(field).attr('name')] = $(field).val()
        m
      , {}
    $.ajax
      type: 'POST'
      url: "/edit-motion/#{doc}/#{char}"
      data: JSON.stringify props: fields
      contentType: 'application/json'
      dataType: 'json'
      success: (data)->
        entry.removeClass(colors).addClass('bg-success')
      error: (xhr, type)->
        entry.removeClass(colors).addClass('bg-error')
  $('.mfield').change ->
    $(this).closest('.column').removeClass(colors).addClass('bg-dark')

  # diff coloring
  motionDiff()
  $('.set-pivot').on 'click', ->
    motionDiff $(this).closest('.column').attr('id')

  # markdown compilation
  marked.setOptions
    breaks: true
    gfm: true
    tables: true
  $('.marked').html (i, t)->
    DOMPurify.sanitize marked t
  