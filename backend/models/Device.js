const mongoose = require('mongoose');

const DeviceSchema = new mongoose.Schema({
  deviceId: { type: String, required: true },
  name: { type: String, required: true },
  ipAddress: { type: String, required: true },
  status: { type: String, default: 'OFF' },
});

module.exports = mongoose.model('Device', DeviceSchema);
