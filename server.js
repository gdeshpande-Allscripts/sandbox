/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable no-console */
const express = require('express');
const path = require('path');

const app = express();
const port = process.env.PORT || 8080;

// Path to webpack built files
const buildPath = path.join(__dirname, 'build');

console.log('Starting CDS Hooks Sandbox server...');
console.log('Build path:', buildPath);
console.log('Port:', port);

// Serve static files from the build directory
app.use(express.static(buildPath));

// Handle SPA routing - send all requests to index.html
app.get('*', (req, res) => {
  res.sendFile(path.join(buildPath, 'index.html'));
});

app.listen(port, () => {
  console.log(`CDS Hooks Sandbox is running on port ${port}`);
});
