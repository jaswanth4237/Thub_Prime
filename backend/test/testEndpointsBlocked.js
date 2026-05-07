const path = require('path');
const express = require('express');

// Inject fake blocked and user models into require cache before routers/controllers are loaded
const blockedPath = path.resolve(__dirname, '..', 'src', 'models', 'blockedAccessModels.js');
const userPath = path.resolve(__dirname, '..', 'src', 'models', 'userModels.js');
const resolvedBlocked = require.resolve(blockedPath);
const resolvedUser = require.resolve(userPath);

function FakeBlockedModel(data) {
  this._doc = data;
  Object.assign(this, data);
}
FakeBlockedModel.prototype.save = async function() {
  this._id = 'fake-block-' + (this.studentId || '1');
  return this;
};

// Fake userModel with updateOne
const FakeUserModel = {
  updateOne: async (query, update) => ({ matchedCount: 1, modifiedCount: 1 })
};

require.cache[resolvedBlocked] = { id: resolvedBlocked, filename: resolvedBlocked, loaded: true, exports: FakeBlockedModel };
require.cache[resolvedUser] = { id: resolvedUser, filename: resolvedUser, loaded: true, exports: FakeUserModel };

// Build app similar to src/app.js but without DB connection
const app = express();
app.use(express.json());

// Attach the real routers; controllers will use the mocked models from cache
const blockedRoutes = require('../src/routes/blockedRouters');
app.use('/blocked', blockedRoutes);

const PORT = 7400;

const server = app.listen(PORT, async () => {
  console.log(`Test server running on ${PORT}`);

  try {
    const base = `http://localhost:${PORT}`;

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

    console.log('-> Test: block student (expect 201)');
    let r = await post('/blocked/block', { studentId: 'stu1', classId: 'C101' });
    console.log(r.status, r.body);

  } catch (err) {
    console.error('Error during endpoint tests:', err);
  } finally {
    server.close(() => console.log('Test server stopped'));
  }
});
