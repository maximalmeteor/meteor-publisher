Template.Posts.events
  'click .more': (event, template) ->
    params = template.subscribeParams.get() or {}
    params.limit = (params.limit or 10) + 1

    template.subscribeParams.set params
