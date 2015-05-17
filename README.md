# maxnowack:publisher
Meteor package that create automatic publications and make template subscriptions easier to use

# Configuration
Publisher needs to be configured on client and server. Mostly the easiest way is to configure Publisher in a file in your `both` folder.

````javascript
Publisher.setupTemplate('NewestPosts', function(data){
  return {
    collection: 'posts',
    query: {},
    limit: 10,
    sort: {
      createdAt: 'desc' // false, 0 and -1 are also possible values for descending
    },
    fields: {
      _id: 1
    },
    security: function(userId) {
      return !!userId; // only allow if user is logged in
    }
  }
});
````

````javascript
Publisher.setupTemplate('Post', function(data){
  return {
    collection: 'posts', // collection from which the data on the template should be
    query: {
      _id: data._id,
    }
    fields: { //
      name: 1,
      author: function(post) {
        return {
          collection: 'authors',
          _id: post.author,
          fields: {
            firstname: 1,
            lastname: 1
          }
        };
      }
    }
  };
});
````
