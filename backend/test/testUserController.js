const path = require('path');

// Resolve and replace the userModels module with a fake implementation
const modelsPath = path.resolve(__dirname, '..', 'src', 'models', 'userModels.js');
const resolved = require.resolve(modelsPath);

// Fake model constructor and static methods
function FakeModel(data) {
  this._doc = data;
  Object.assign(this, data);
}

FakeModel.prototype.save = async function() {
  this._id = 'fake-id-' + (this.userId || '1');
  return this;
};

// Default: no existing user
let findOneImpl = async (query) => null;

FakeModel.findOne = async function(query) {
  return findOneImpl(query);
};

// Inject into require cache
require.cache[resolved] = {
  id: resolved,
  filename: resolved,
  loaded: true,
  exports: FakeModel
};

// Now require the controller which uses ../models/userModels
const controller = require('../src/controller/userController');

// Simple mock response collector
function makeRes() {
  const res = {};
  res.statusCode = 200;
  res.body = null;
  res.status = function(code) { this.statusCode = code; return this; };
  res.json = function(obj) { this.body = obj; return this; };
  return res;
}

async function testCreateSuccess() {
  const req = { body: { userId: 'user1', role: 'student' } };
  const res = makeRes();
  await controller.createUser(req, res);
  console.log('Create Success =>', res.statusCode, JSON.stringify(res.body));
}

async function testCreateDuplicate() {
  // Make findOne return an existing user
  findOneImpl = async (query) => ({ userId: query.userId, role: 'student' });
  const req = { body: { userId: 'user1', role: 'student' } };
  const res = makeRes();
  await controller.createUser(req, res);
  console.log('Create Duplicate =>', res.statusCode, JSON.stringify(res.body));
}

(async () => {
  console.log('Running userController tests...');
  await testCreateSuccess();
  await testCreateDuplicate();
})();
