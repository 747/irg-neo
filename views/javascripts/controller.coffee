Zepto ($)->

  motionDiff = (ref)->
    sameStyle = 'rounded diff-same'
    diffStyle = 'rounded diff-unsame'
    activeStyle = 'btn-primary'
    targets = $('.motion:not(.unified):not(#editor)')
    names = targets.map -> $(this).attr('id')
    matrix = targets.map -> [$(this).children('.comparable')] # flatten-proof
    pivot = Math.max names.indexOf(ref), 0 # 0 if not found
    matrix.each (i, e)->
      method = if i == pivot then 'addClass' else 'removeClass'
      $(e).closest('column').find('.set-pivot')[method]('btn-primary')
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
  $('.toggle-unified').on 'click', ->
    # nextUntil equivalent
    n = $(this).closest('.motion').next()
    while n.is('.unified')
      n.toggle()
      n = n.next()
      break if n.length is 0

    $(this).toggleClass('btn-primary')
    .find('.icon').toggleClass('icon-resize-horiz icon-arrow-right')

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
    doc = $('#inedition').data('edit')
    set = $('#current').data('set')
    char = $('#current').data('code')
    entry = $(this).closest('.column')
    fields = $('.mfield').reduce (m, field)->
        m[$(field).attr('name')] = $(field).val()
        m
      , {}
    $.ajax
      type: 'POST'
      url: "/edit-motion/#{doc}/#{char}"
      data: JSON.stringify
        props: fields
        ref:
          set: set
      contentType: 'application/json'
      dataType: 'json'
      success: (data)->
        entry.removeClass(colors).addClass('bg-success')
      error: (xhr, type)->
        entry.removeClass(colors).addClass('bg-error')
  $('.mfield').change ->
    $(this).closest('.column').removeClass(colors).addClass('bg-dark')

  $('.mirror').on 'click', ->
    origin = $(this).closest('.column')
    dest = $('#editor')
    dest.find('[name]').each (i, t)->
      item = $(t)
      name = item.attr 'name'
      item.val origin.find(".field-#{name}").data('value')

  # diff coloring
  motionDiff()
  $('.set-pivot').on 'click', ->
    motionDiff $(this).closest('.column').attr('id')

  # markdown compilation
  marked.setOptions
    breaks: true
    gfm: true
    tables: true
    smartypants: true
  $('.marked').html (i, t)->
    DOMPurify.sanitize marked t
  