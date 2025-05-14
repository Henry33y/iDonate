const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Initialize Firebase Admin SDK
const serviceAccount = require('./service-account.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'idonate-c030e',
});

// Endpoint to get FCM access token
app.get('/api/fcm/token', async (req, res) => {
  try {
    const token = await admin.messaging().getAccessToken();
    res.json({ token });
  } catch (error) {
    console.error('Error getting FCM token:', error);
    res.status(500).json({ error: 'Failed to get FCM token' });
  }
});

// Endpoint to send FCM notification
app.post('/api/fcm/send', async (req, res) => {
  try {
    const { token, title, body, data } = req.body;
    
    console.log('Received notification request:', {
      token: token ? `${token.substring(0, 10)}...` : 'missing',
      title,
      body,
      data
    });
    
    if (!token) {
      console.error('FCM token is missing in request');
      return res.status(400).json({ error: 'FCM token is required' });
    }

    const message = {
      token,
      notification: {
        title,
        body,
      },
      data: Object.keys(data).reduce((acc, key) => {
        acc[key] = String(data[key]); // Convert all values to strings
        return acc;
      }, {}),
      android: {
        priority: 'high',
        notification: {
          channelId: 'blood_requests',
          priority: 'high',
          defaultSound: true,
          defaultVibrateTimings: true,
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
            contentAvailable: true,
          },
        },
      },
    };

    console.log('Sending FCM message with configuration:', JSON.stringify(message, null, 2));
    
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message. Response:', response);
    res.json({ success: true, messageId: response });
  } catch (error) {
    console.error('Error sending FCM message:', error);
    console.error('Error details:', {
      code: error.code,
      message: error.message,
      stack: error.stack
    });
    res.status(500).json({ 
      error: 'Failed to send FCM message', 
      details: error.message,
      code: error.code 
    });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
}); 