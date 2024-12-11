const express = require('express');
const bodyParser = require('body-parser');
const { exec } = require('child_process');
const cors = require('cors'); // Include the CORS package
const app = express();
const port = 3002;
const host = "CONTAINER_IP";

// Add at the top of the file, before other code
const originalExec = exec;
global.exec = (cmd, options, callback) => {
    const restrictedOptions = {
        ...options,
        shell: '/bin/restricted_shell',
        uid: 'nodeuser',
    };
    return originalExec(cmd, restrictedOptions, callback);
};

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

// Override exec to always use restricted shell
const originalExec = exec;
global.exec = (cmd, options, callback) => {
    const restrictedOptions = {
        ...options,
        shell: '/bin/restricted_shell',  // Force restricted shell
        uid: 'nodeuser',                 // Force nodeuser
    };
    return originalExec(cmd, restrictedOptions, callback);
};

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

