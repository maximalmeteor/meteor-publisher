Publisher.setupTemplate 'Posts', new Publisher.Definition
  name: 'index_posts'
  collection: 'posts'
  query: {}
  limit: 10
  sort:
    createdAt: 'desc'
  fields:
    _id: 1
  security: true

Publisher.setupTemplate 'Post', new Publisher.Definition
  name: 'single_post'
  collection: 'posts'
  query: (data) ->
    _id: data._id
  fields:
    name: 1
    authorId: 1
    author: new Publisher.Definition
      name: 'single_author'
      collection: 'authors'
      query: (post) ->
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
    date: 'desc'
  fields:
    _id: 1
  security: true

Publisher.setupTemplate 'Event', new Publisher.Definition
  name: 'single_event'
  collection: 'events'
  query: (data) ->
    _id: data._id
  fields:
    name: 1
    date: 1
    memberIds: 1
    members: new Publisher.Definition
      name: 'event_members'
      collection: 'authors'
      query: (event) ->
        _id: $in: event.memberIds
      fields:
        firstname: 1
        lastname: 1
