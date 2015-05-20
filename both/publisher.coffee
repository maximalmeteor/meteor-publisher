@Publisher = class Publisher
  @setupTemplate: (templateName, definition) ->
    check templateName, String
    check definition, Publisher.Definition

    if Meteor.isServer
      Publisher._log
        msg: 'setupTemplate called on server'
        level: 'info'

    if Meteor.isClient
      template = Template[templateName]
      template.helpers
        data: ->
          instance = Template.instance()
          return unless instance?
          modified = instance.modifiedData.get()
          published = instance.publishedData.get()

          if modified?
            return modified
          else
            return published
      template.onCreated ->
        @publishedData = new ReactiveVar()
        @modifiedData = new ReactiveVar()
        @subscribeParams = new ReactiveVar()

        @autorun =>
          subscribeParams = @subscribeParams.get()
          query = definition.query @data, subscribeParams
          options = definition.getOptions subscribeParams
          cursor = definition.collection.find query, options
          if definition.options.limit is 1
            @publishedData.set cursor.fetch()[0]
          else
            @publishedData.set cursor

        @autorun =>
          data = @publishedData.get()
          @modifiedData.set definition.resolveFields template, this, data

        @autorun =>
          @subscribe definition.name, @data, @subscribeParams.get()

  @Definition: Definition
  @Utilities: Utilities
  @debug = false
  @_log: (options) ->
    return unless Publisher.debug
    levels = ['log', 'info', 'debug', 'warn', 'error']
    options.level = 'log' unless options.level in levels
    console[options.level] options.msg
