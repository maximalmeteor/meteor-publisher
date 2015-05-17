Publisher.setupTemplate 'Index', (data) ->
  collection: 'posts',
  query: {}
  limit: 10
  sort:
    createdAt: 'desc'
  fields:
    _id: 1
  security: (userId) ->
    !!userId

Publisher.setupTemplate 'Post', (data) ->
  collection: 'posts'
  query:
    _id: data._id
  fields:
    name: 1
    author: (post) ->
      collection: 'authors'
      _id: post.author
      fields:
        firstname: 1
        lastname: 1
