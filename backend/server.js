const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();
const ping = require('net-ping');
const mqtt = require('mqtt');

const app = express();
app.use(bodyParser.json());
app.use(cors());

// Initialize SQLite Database
const db = new sqlite3.Database('devices.db');

// Create Devices Table
db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS devices (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      deviceId TEXT NOT NULL,
      name TEXT NOT NULL,
      ipAddress TEXT NOT NULL,
      status TEXT DEFAULT 'OFF'
    )
  `);
});

// Device Discovery
const discoverDevices = async () => {
  const session = ping.createSession();
  const localNetwork = '192.168.1.'; // Replace with your local subnet
  console.log(`Starting device discovery on subnet: ${localNetwork}`);

  for (let i = 1; i <= 255; i++) {
    const ip = `${localNetwork}${i}`;
    session.pingHost(ip, (error) => {
      if (!error) {
        db.get('SELECT * FROM devices WHERE ipAddress = ?', [ip], (err, row) => {
          if (!row) {
            db.run(
              'INSERT INTO devices (deviceId, name, ipAddress, status) VALUES (?, ?, ?, ?)',
              [`Device-${i}`, `Device ${i}`, ip, 'OFF'],
              () => {
                console.log(`Discovered and added: ${ip}`);
              }
            );
          } else {
            console.log(`Device already exists: ${ip}`);
          }
        });
      } else {
        console.log(`Device not reachable: ${ip}`);
      }
    });
  }
};

// MQTT Connection
const mqttClient = mqtt.connect('mqtt://broker.hivemq.com');
mqttClient.on('connect', () => {
  console.log('Connected to MQTT broker');
  mqttClient.subscribe('devices/status');
});

mqttClient.on('message', (topic, message) => {
  console.log(`Received message on ${topic}: ${message}`);
});

// REST API

// Get all devices
app.get('/devices', (req, res) => {
  db.all('SELECT * FROM devices', (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// Add a new device
app.post('/devices', (req, res) => {
  const { deviceId, name, ipAddress, status } = req.body;
  db.run(
    'INSERT INTO devices (deviceId, name, ipAddress, status) VALUES (?, ?, ?, ?)',
    [deviceId, name, ipAddress, status || 'OFF'],
    function (err) {
      if (err) return res.status(400).json({ error: err.message });
      res.status(201).json({
        id: this.lastID,
        deviceId,
        name,
        ipAddress,
        status: status || 'OFF',
      });
    }
  );
});

// Update a device
app.put('/devices/:id', (req, res) => {
  const { id } = req.params;
  const { name, ipAddress, status } = req.body;

  // Retrieve existing data for the device
  db.get('SELECT * FROM devices WHERE id = ?', [id], (err, row) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    if (!row) {
      return res.status(404).json({ error: 'Device not found' });
    }

    // Use existing values if fields are not provided in the request
    const updatedName = name || row.name;
    const updatedIpAddress = ipAddress || row.ipAddress;
    const updatedStatus = status || row.status;

    db.run(
      'UPDATE devices SET name = ?, ipAddress = ?, status = ? WHERE id = ?',
      [updatedName, updatedIpAddress, updatedStatus, id],
      function (err) {
        if (err) {
          return res.status(400).json({ error: err.message });
        }
        res.json({ message: 'Device updated' });
      }
    );
  });
});



// Delete a device
app.delete('/devices/:id', (req, res) => {
  const { id } = req.params;
  db.run('DELETE FROM devices WHERE id = ?', id, function (err) {
    if (err) return res.status(400).json({ error: err.message });
    if (this.changes === 0) return res.status(404).json({ error: 'Device not found' });
    res.json({ message: 'Device deleted' });
  });
});

// 404 Route
app.get('*', (req, res) => {
  res.status(404).send('Route not found');
});

// Start the server
app.listen(5000, async () => {
  console.log('Server running on port 5000');
  await discoverDevices(); // Run device discovery on startup
});
