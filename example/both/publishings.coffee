Publisher.setupTemplate 'Posts', new Publisher.Definition
  name: 'index_posts'
  collection: 'posts'
  query: {}
  limit: 10
  sort:
    createdAt: -1
  fields:
    _id: 1
  security: true

Publisher.setupTemplate 'Post', new Publisher.Definition
  name: 'single_post'
  collection: 'posts'
  query: (data) ->
    _id: data._id
  limit: 1
  fields:
    name: 1
    authorId: 1
    author: new Publisher.Definition
      name: 'single_author'
      limit: 1
      collection: 'authors'
      query: (post) ->
        return unless post.authorId?
        _id: post.authorId
      fields:
        firstname: 1
        lastname: 1

Publisher.setupTemplate 'Events', new Publisher.Definition
  name: 'index_events'
  collection: 'events'
  query: {}
  limit: 10
  sort:
    date: -1
  fields:
    _id: 1
  security: true

Publisher.setupTemplate 'Event', new Publisher.Definition
  name: 'single_event'
  collection: 'events'
  query: (data) ->
    _id: data._id
  limit: 1
  fields:
    name: 1
    date: 1
    memberIds: 1
    members: new Publisher.Definition
      name: 'event_members'
      collection: 'authors'
      query: (event) ->
        return unless event.memberIds?
        _id: $in: event.memberIds
      fields:
        firstname: 1
        lastname: 1
