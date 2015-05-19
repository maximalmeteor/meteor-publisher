Meteor.startup ->
  Posts.remove {}
  Companies.remove {}
  Events.remove {}
  Authors.remove {}

  authorId = null
  for i in [0...20]
    companyId = Companies.insert
      name: Fake.word()
      managerId: authorId

    user = Fake.user()
    authorId = Authors.insert
      firstname: user.name
      lastname: user.surname
      email: user.email
      companyId: companyId

    Posts.insert
      name: Fake.sentence 5
      authorId: authorId
      body: Fake.paragraph 10
      createdAt: new Date()

    Events.insert
      name: Fake.sentence 3
      date: new Date()
      memberIds: Authors.find().map (author) -> author._id
