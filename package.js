Package.describe({
  name: 'maxnowack:publisher',
  version: '0.0.1',
  summary: 'Package that create automatic publications and make template subcriptions easier to use',
  git: 'https://github.com/maxnowack/meteor-publisher',
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.use('reactive-var');
  api.use('dburles:mongo-collection-instances@0.3.3');

  var server = 'server';
  var client = 'client';
  var both = [server, client];

  api.addFiles([], server);
  api.addFiles([], client);
  api.addFiles([
    'both/utilities.coffee',
    'both/definition.coffee',
    'both/publisher.coffee'
  ], both);

  api.export('Publisher');
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('coffeescript');
  api.use('maxnowack:publisher');

  var server = 'server';
  var client = 'client';
  var both = [server, client];

  api.addFiles([], server);
  api.addFiles([], client);
  api.addFiles([], both);
});
