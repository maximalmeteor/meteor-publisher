@Publisher = class Publisher
  @setupTemplate: (templateName, definition) ->
    check templateName, String
    check definition, Publisher.Definition

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
          query = definition.query(@data)
          options = definition.getOptions @subscribeParams.get()
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
