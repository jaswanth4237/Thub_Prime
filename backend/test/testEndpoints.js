const path = require('path');
const express = require('express');

// Inject fake user model into require cache before routers/controllers are loaded
const modelsPath = path.resolve(__dirname, '..', 'src', 'models', 'userModels.js');
const resolved = require.resolve(modelsPath);

function FakeModel(data) {
  this._doc = data;
  Object.assign(this, data);
}

FakeModel.prototype.save = async function() {
  this._id = 'fake-id-' + (this.userId || '1');
  return this;
};

let findOneImpl = async (query) => null;
FakeModel.findOne = async function(query) {
  return findOneImpl(query);
};

require.cache[resolved] = {
  id: resolved,
  filename: resolved,
  loaded: true,
  exports: FakeModel
};

// Build app similar to src/app.js but without DB connection
const app = express();
app.use(express.json());

// Attach the real routers; controllers will use the mocked model from cache
const userRoutes = require('../src/routes/userRouters');
app.use('/user', userRoutes);

const PORT = 7200;

const server = app.listen(PORT, async () => {
  console.log(`Test server running on ${PORT}`);

  // Run tests
  try {
    const base = `http://localhost:${PORT}`;

    // Helper for POST
    async function post(path, body) {
      const res = await fetch(base + path, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
      });
      const text = await res.text();
      let parsed;
      try { parsed = JSON.parse(text); } catch (e) { parsed = text; }
      return { status: res.status, body: parsed };
    }

    console.log('-> Test: create user (expect 201)');
    let r = await post('/user/add', { userId: 'userX', role: 'student' });
    console.log(r.status, r.body);

    console.log('-> Test: create duplicate user (expect 400)');
    // make model findOne return an existing user
    findOneImpl = async (q) => ({ userId: q.userId, role: 'student' });
    r = await post('/user/add', { userId: 'userX', role: 'student' });
    console.log(r.status, r.body);

  } catch (err) {
    console.error('Error during endpoint tests:', err);
  } finally {
    server.close(() => console.log('Test server stopped'));
  }
});
