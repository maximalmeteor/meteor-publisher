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
