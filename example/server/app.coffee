Meteor.startup ->
  Posts.remove {}
  Events.remove {}
  Authors.remove {}

  for i in [0...20]
    user = Fake.user()
    authorId = Authors.insert
      firstname: user.name
      lastname: user.surname
      email: user.email

    Posts.insert
      name: Fake.sentence 5
      authorId: authorId
      body: Fake.paragraph 10
      createdAt: new Date()

    Events.insert
      name: Fake.sentence 3
      date: new Date()
      memberIds: Authors.find().map (author) -> author._id
