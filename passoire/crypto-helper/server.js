const express = require('express');
const bodyParser = require('body-parser');
const { exec } = require('child_process');
const cors = require('cors'); // Include the CORS package
const app = express();
const port = 3002;
const host = "CONTAINER_IP";
const crypto = require('crypto');

// Middleware to parse request body
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  next();
});

app.options('*', (req, res) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  res.sendStatus(200);
});

// Hashing APIs
app.post('/hash/:type', (req, res) => {
  const { type } = req.params;
  const { text } = req.body;
  
  if (!text || typeof text !== 'string') {
    return res.status(400).send({error: "Invalid input"});
  }

  try {
    const hash = crypto.createHash(type).update(text).digest('hex');
    res.send({ hash });
  } catch (error) {
    res.status(500).send({error: "Hashing failed"});
  }
});

// DES Encrypt API
app.post('/encrypt/des', (req, res) => {
  const { text, key } = req.body;

	const cmd =`openssl des-ecb -e -K ${key} -in <(echo "${text}") -base64`;
  console.log(cmd);
  exec(cmd,{shell: '/bin/bash'}, (error, stdout) => {
    if (error) {
      return res.status(500).send({error: error.message});
    }
    res.send({ encrypted: stdout.trim() });
  });
});

// DES Decrypt API
app.post('/decrypt/des', (req, res) => {
  const { text, key } = req.body;


	const cmd =`openssl des-ecb -d -K ${key} -in <(echo "${text}") -base64`;
  console.log(cmd);
  exec(cmd,{shell: '/bin/bash'}, (error, stdout) => {
    if (error) {
      return res.status(500).send({error: error.message});
    }
    res.send({ decrypted: stdout.trim() });
  });
});

// AES Encrypt API
app.post('/encrypt/aes', (req, res) => {
  const { text, key } = req.body;
  
  if (!text || !key || typeof text !== 'string' || typeof key !== 'string') {
    return res.status(400).send({error: "Invalid input"});
  }

  try {
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv('aes-256-cbc', Buffer.from(key), iv);
    let encrypted = cipher.update(text, 'utf8', 'base64');
    encrypted += cipher.final('base64');
    res.send({ encrypted, iv: iv.toString('hex') });
  } catch (error) {
    res.status(500).send({error: "Encryption failed"});
  }
});

// AES Decrypt API
app.post('/decrypt/aes', (req, res) => {
  const { text, key } = req.body;

	const cmd =`echo "${text}" | openssl enc -aes-256-cbc -d -base64 -pass pass:"${key}" -iv 00000000000000000000000000000000`;
  console.log(cmd);
  exec(cmd,{shell: '/bin/bash'}, (error, stdout) => {
    if (error) {
      return res.status(500).send({error: error.message});
    }
    res.send({ decrypted: stdout.trim() });
  });
});

// Start the server
app.listen(port, () => {
  console.log(`Crypto API running at http://${host}:${port}`);
});

