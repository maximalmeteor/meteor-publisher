Publisher =
  setupTemplate: (templateName, definition) ->
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
        @autorun =>
          cursor = definition.collection.find definition.query(this.data), definition.getOptions()
          if definition.options.limit is 1
            @publishedData.set cursor.fetch()[0]
          else
            @publishedData.set cursor
        @autorun =>
          @modifiedData.set definition.resolveFields template, this, @publishedData.get()
        @autorun =>
          @subscribe definition.name, @data

  Definition: Definition
