# maxnowack:publisher
Meteor package that create automatic publications and make template subscriptions easier to use

# Configuration

#### Server
````javascript
Publisher.configure({
  whitelist: { // you can configure a whitelist or a blacklist
    posts: [ // name of a collection
      'name', // fieldnames
      'author'
    ]
  }
  //blacklist: {}
});
````

#### Client
````javascript
Publisher.setupTemplate(Template.NewestPosts, function(data){
  return {
    
  }
});
````

````javascript
Publisher.setupTemplate(Template.Post, function(data){
  return {
    collection: 'posts', // collection from which the data on the template should be
    _id: data._id,
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
