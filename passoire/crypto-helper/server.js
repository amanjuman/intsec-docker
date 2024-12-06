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
  const allowedHashes = ['md5', 'sha1'];

  if (!allowedHashes.includes(type)) {
    return res.status(400).send({error: "Invalid hash type. Use \"md5\" or \"sha1\"."});
  }
	const cmd = `echo -n "${text}" | openssl dgst -${type}`;
  console.log(cmd);
	
  exec(cmd,{shell: '/bin/bash'}, (error, stdout) => {
    if (error) {
      return res.status(500).send({error: error.message});
    }
    res.send({ hash: stdout.split("= ")[1].trim() });
  });
});

// app.post('/encrypt/des', (req, res) => {
//     const { text, key } = req.body;
  
//       const cmd =`openssl des-ecb -e -K ${key} -in <(echo "${text}") -base64`;
//     console.log(cmd);
//     exec(cmd,{shell: '/bin/bash'}, (error, stdout) => {
//       if (error) {
//         return res.status(500).send({error: error.message});
//       }
//       res.send({ encrypted: stdout.trim() });
//     });
//   });

// DES Encrypt API
app.post('/encrypt/des', (req, res) => {
  try {
    const { text, key } = req.body;
    
    // Input validation
    if (!text || !key || typeof text !== 'string' || typeof key !== 'string') {
      return res.status(400).json({ error: 'Invalid input parameters' });
    }

    // Create key buffer of correct length
    const keyBuffer = crypto.scryptSync(key, 'salt', 8); // DES uses 64-bit key
    const iv = Buffer.alloc(8, 0); // DES uses 64-bit IV
    
    const cipher = crypto.createCipheriv('des-ecb', keyBuffer, iv);
    let encrypted = cipher.update(text, 'utf8', 'base64');
    encrypted += cipher.final('base64');
    
    res.json({ encrypted });
  } catch (error) {
    console.error('Encryption error:', error);
    res.status(500).json({ error: 'Encryption failed' });
  }
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

	const cmd =`echo -n "${text}" | openssl enc -aes-256-cbc -base64 -pass pass:"${key}" -iv 00000000000000000000000000000000`;
  console.log(cmd);
  exec(cmd,{shell: '/bin/bash'}, (error, stdout) => {
    if (error) {
      return res.status(500).send({error: error.message});
    }
    res.send({ encrypted: stdout.trim() });
  });
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

