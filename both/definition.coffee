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
    Meteor.publish definition.name, (params) ->
      if definition.security?
        if typeof definition.security is 'function'
          return @ready() unless definition.security @userId
        else
          return @ready() unless definition.security
      query = definition.query(params)
      return @ready() unless query
      definition.collection.find query, definition.getOptions()
  extendItem: (template, instance, name, field, item) ->
    return unless item?
    instance.subscribe field.name, item
    data = new ReactiveVar()
    modified = new ReactiveVar()
    instance.autorun ->
      cur = field.collection.find field.query(item), field.getOptions()
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

  getOptions: ->
    options = {}
    fields = {}
    for name, field of @fields
      fields[name] = if !!field then 1 else 0

    options.fields = fields unless _.isEmpty fields
    options.limit = @options.limit if @options.limit?
    options.sort = @options.sort if @options.sort?

    return options
