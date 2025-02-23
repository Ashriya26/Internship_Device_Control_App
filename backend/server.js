const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const dotenv = require('dotenv');
const Device = require('./models/Device');
const ping = require('net-ping');
const mqtt = require('mqtt');

dotenv.config();
const app = express();
app.use(bodyParser.json());
app.use(cors());

// MongoDB Connection
mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('MongoDB connected'))
  .catch((err) => console.error(err));

// Device Discovery
const discoverDevices = async () => {
  const session = ping.createSession();
  const localNetwork = '192.168.1.'; // Example subnet
  for (let i = 1; i <= 255; i++) {
    const ip = `${localNetwork}${i}`;
    session.pingHost(ip, async (error) => {
      if (!error) {
        const existingDevice = await Device.findOne({ ipAddress: ip });
        if (!existingDevice) {
          const newDevice = new Device({ deviceId: `Device-${i}`, name: `Device ${i}`, ipAddress: ip });
          await newDevice.save();
          console.log(`Discovered and added: ${ip}`);
        }
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


app.get('/devices', async (req, res) => {
  console.log('GET /devices route accessed');
  const devices = await Device.find();
  res.json(devices);
});

app.get('*', (req, res) => {
  res.status(404).send('Route not found');
});


app.listen(process.env.PORT, async () => {
  console.log(`Server running on port ${process.env.PORT}`);
  await discoverDevices(); // Run device discovery on startup
});
