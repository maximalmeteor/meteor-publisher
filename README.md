# maximal:publisher
Meteor package that create automatic publications and make template subscriptions easier to use

# Configuration
Publisher needs to be configured on client and server. Mostly the easiest way is to configure Publisher in a file in your `both` folder.

````javascript
Publisher.setupTemplate('Index', new Publisher.Definition({
  name: 'index_posts',
  collection: 'posts',
  query: {},
  limit: 10,
  sort: {
    createdAt: 'desc'
  },
  fields: {
    _id: 1
  },
  security: true
}));
````

````javascript
Publisher.setupTemplate('Post', new Publisher.Definition({
  name: 'single_post',
  collection: 'posts',
  query: function(data) {
    return {
      _id: data._id
    };
  },
  fields: {
    name: 1,
    authorId: 1,
    author: new Publisher.Definition({
      name: 'single_author',
      collection: 'authors',
      query: function(post) {
        return {
          _id: post.authorId
        };
      },
      fields: {
        firstname: 1,
        lastname: 1
      }
    })
  }
}));
````
