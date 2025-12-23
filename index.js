/* eslint-disable import/no-extraneous-dependencies */
const express = require('express');
const path = require('path');

const app = express();

// path to webpack built path
const buildPath = path.join(__dirname, 'build');

app.use(express.static(buildPath));

// Fallback to index.html for client-side routing
app.get('*', (req, res) => {
  res.sendFile(path.join(buildPath, 'index.html'));
});

module.exports = app;
