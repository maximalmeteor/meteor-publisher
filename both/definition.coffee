@Definition = class Definition
  constructor: (definition) ->
    @name = definition.name
    @collection = ->
      Mongo.Collection.get definition.collection

    if typeof definition.query is 'function'
      @query = definition.query
    else
      @query = -> definition.query

    if typeof definition.params is 'function'
      @params = definition.params
    else
      @params = (data) -> data

    @options =
      limit: definition.limit
      sort: definition.sort

    @fields = definition.fields
    @security = definition.security

    @publish() if Meteor.isServer
  publish: ->
    definition = this
    Meteor.publish definition.name, (params, subscribeParams) ->
      if definition.security?
        if typeof definition.security is 'function'
          return @ready() unless definition.security @userId
        else
          return @ready() unless definition.security
      query = definition.query(params, subscribeParams)
      return @ready() unless query
      definition.collection().find query, definition.getOptions subscribeParams
  extendItem: (template, instance, name, field, item) ->
    return unless item?
    subscribeParams = instance.subscribeParams.get()
    instance.subscribe field.name, field.params(item), subscribeParams
    data = new ReactiveVar()
    modified = new ReactiveVar()
    instance.autorun ->
      subscribeParams = instance.subscribeParams.get()
      options = field.getOptions subscribeParams
      cur = field.collection().find field.query(item, subscribeParams), options
      if field.options.limit is 1
        data.set cur.fetch()[0]
      else
        data.set cur
    instance.autorun ->
      modified.set field.resolveFields template, instance, data.get()

    obj = {}
    obj[name] = ->
      modified.get() or data.get()
    _.extend item, obj
  resolveFields: (template, instance, currentData) ->
    for name, field of @fields when field instanceof Publisher.Definition
      if currentData instanceof Mongo.Cursor
        currentData = currentData.fetch()

      Tracker.nonreactive =>
        if currentData instanceof Array
          for item in currentData
            item = @extendItem template, instance, name, field, item
        else
          currentData = @extendItem template, instance, name, field, currentData

    return currentData

  getOptions: (params) ->
    options = {}
    fields = {}
    for name, field of @fields
      fields[name] = if !!field then 1 else 0

    options.fields = fields unless _.isEmpty fields
    if limit = @options.limit
      options.limit = Publisher.Utilities.applyParams limit, this, params
    if sort = @options.sort
      options.sort = Publisher.Utilities.applyParams sort, this, params

    return options
