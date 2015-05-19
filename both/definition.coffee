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
  publish: ->
    definition = this
    definition.resolveFields()
    Meteor.publish definition.name, (params) ->
      if definition.security?
        if typeof definition.security is 'function'
          return unless definition.security @userId
        else
          return unless definition.security
      query = definition.query(params)
      return unless query
      definition.collection.find query, definition.getOptions()
  extendItem: (instance, name, field, item) ->
    instance.subscribe field.name, item

    obj = {}
    obj[name] = ->
      cur = field.collection.find field.query(item), field.getOptions()
      if field.options.limit is 1
        cur.fetch()[0]
      else
        cur
    _.extend item, obj
  resolveFields: (template, instance, currentData) ->
    for name, field of @fields when field instanceof Publisher.Definition
      if Meteor.isServer
        field.publish()
        field.resolveFields()

      if Meteor.isClient
        if currentData instanceof Mongo.Cursor
          currentData = currentData.fetch()

        if currentData instanceof Array
          for item in currentData
            item = @extendItem instance, name, field, item
        else
          currentData = @extendItem instance, name, field, currentData

        currentData = field.resolveFields template, instance, currentData
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
