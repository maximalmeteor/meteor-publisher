Meteor.startup ->
  Posts.remove {}
  Authors.remove {}

  for i in [0...20]
    user = Fake.user()
    authorId = Authors.insert
      firstname: user.name
      lastname: user.surname
      email: user.email

    Posts.insert
      name: Fake.sentence 5
      author: authorId
      body: Fake.paragraph 10
      createdAt: new Date()
