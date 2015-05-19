@Definition = class Definition
  constructor: (definition) ->
    @name = definition.name
    @collection = Mongo.Collection.get definition.collection

    if typeof definition.query is 'function'
      @query = definition.query
    else
      @query = -> definition.query

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
      query = definition.query(params)
      return @ready() unless query
      definition.collection.find query, definition.getOptions subscribeParams
  extendItem: (template, instance, name, field, item) ->
    return unless item?
    instance.subscribe field.name, item, instance.subscribeParams.get()
    data = new ReactiveVar()
    modified = new ReactiveVar()
    instance.autorun ->
      options = field.getOptions instance.subscribeParams.get()
      cur = field.collection.find field.query(item), options
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
    if @options.limit?
      options.limit = Publisher.Utilities.applyParams @options.limit, this, params
    if @options.sort?
      options.sort = Publisher.Utilities.applyParams @options.sort, this, params

    return options
