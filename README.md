# maximal:publisher
Meteor package that create automatic publications and make template subscriptions easier to use

# Usage
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

It's also possible to initialize the definitions on client and server.

````javascript
var PublisherDefinitions = {};

PublisherDefinitions.LatestPosts = new Publisher.Definition({
  name: 'index_posts',
  collection: 'posts',
  query: {},
  limit: function(params) {
    if(!params) return;
    return params.limit || 10;
  },
  sort: {
    createdAt: -1
  },
  fields: {
    _id: 1
  },
  security: true
});

PublisherDefinitions.Company = new Publisher.Definition({
  name: 'single_company',
  limit: 1,
  collection: 'companies',
  query: function(author) {
    if (!(author) return;
    if (!(author.companyId) return;

    return {
      _id: author.companyId
    };
  },
  fields: {
    name: 1,
    managerId: 1,
    manager: new Publisher.Definition({
      name: 'company_manager',
      limit: 1,
      query: function(company) {
        if (!(company) return;
        if (!(company.managerId) return;

        return {
          _id: company.managerId
        };
      },
      collection: 'authors',
      fields: {
        firstname: 1,
        lastname: 1
      }
    })
  }
});

PublisherDefinitions.SinglePost = new Publisher.Definition({
  name: 'single_post',
  collection: 'posts',
  query: function(data) {
    return {
      _id: data._id
    };
  },
  limit: 1,
  fields: {
    name: 1,
    authorId: 1,
    author: new Publisher.Definition({
      name: 'single_author',
      limit: 1,
      collection: 'authors',
      query: function(post) {
        if (!post.authorId) return;

        return {
          _id: post.authorId
        };
      },
      fields: {
        firstname: 1,
        lastname: 1,
        companyId: 1,
        company: PublisherDefinitions.Company
      }
    })
  }
});

PublisherDefinitions.Events = new Publisher.Definition({
  name: 'index_events',
  collection: 'events',
  query: {},
  limit: 10,
  sort: {
    date: -1
  },
  fields: {
    _id: 1
  },
  security: true
});

PublisherDefinitions.Event = new Publisher.Definition({
  name: 'single_event',
  collection: 'events',
  query: function(data) {
    return {
      _id: data._id
    };
  },
  limit: 1,
  fields: {
    name: 1,
    date: 1,
    memberIds: 1,
    members: new Publisher.Definition({
      name: 'event_members',
      collection: 'authors',
      query: function(event) {
        if (!event.memberIds) return;

        return {
          _id: {
            $in: event.memberIds
          }
        };
      },
      fields: {
        firstname: 1,
        lastname: 1,
        companyId: 1,
        company: PublisherDefinitions.Company
      }
    })
  }
});
````

Then you can setup the templates on client only.
````javascript
Publisher.setupTemplate 'Posts', PublisherDefinitions.LatestPosts
Publisher.setupTemplate 'Post', PublisherDefinitions.SinglePost
Publisher.setupTemplate 'Events', PublisherDefinitions.Events
Publisher.setupTemplate 'Event', PublisherDefinitions.Event
````

## Debugging
You can enable debug logging by setting `Publisher.debug = true`
