const path = require('path');
const express = require('express');

// Inject fake class model into require cache before routers/controllers are loaded
const modelsPath = path.resolve(__dirname, '..', 'src', 'models', 'classModels.js');
const resolved = require.resolve(modelsPath);

function FakeClassModel(data) {
  this._doc = data;
  Object.assign(this, data);
}

let shouldThrowOnSave = false;

FakeClassModel.prototype.save = async function() {
  if (shouldThrowOnSave) {
    const err = new Error('E11000 duplicate key error');
    err.code = 11000;
    throw err;
  }
  this._id = 'fake-class-' + (this.classId || '1');
  return this;
};

FakeClassModel.findOne = async function(query) { return null; };

require.cache[resolved] = {
  id: resolved,
  filename: resolved,
  loaded: true,
  exports: FakeClassModel
};

// Build app similar to src/app.js but without DB connection
const app = express();
app.use(express.json());

// Attach the real routers; controllers will use the mocked model from cache
const classRoutes = require('../src/routes/classRouters');
app.use('/class', classRoutes);

const PORT = 7300;

const server = app.listen(PORT, async () => {
  console.log(`Test server running on ${PORT}`);

  // Run tests
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

    console.log('-> Test: create class (expect 201)');
    let r = await post('/class/add', { classId: 'C101', className: 'Math 101', mentorId: 'M1', schedule: 'Mon 10-12' });
    console.log(r.status, r.body);

    console.log('-> Test: create duplicate class (simulate duplicate, expect error)');
    shouldThrowOnSave = true; // simulate duplicate key error on save
    r = await post('/class/add', { classId: 'C101', className: 'Math 101', mentorId: 'M1', schedule: 'Mon 10-12' });
    console.log(r.status, r.body);

  } catch (err) {
    console.error('Error during endpoint tests:', err);
  } finally {
    server.close(() => console.log('Test server stopped'));
  }
});
