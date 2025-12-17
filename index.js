// /functions/index.js

// FIX: Using the V1 specific import path for stable deployment on Node 20.
const functions = require('firebase-functions/v1'); 
const admin = require('firebase-admin');

// FIX: Explicitly initialize the Admin SDK for the current project.
// process.env.GCLOUD_PROJECT contains the project ID ("better-health-insurance").
admin.initializeApp({
    projectId: process.env.GCLOUD_PROJECT
});

const db = admin.firestore();

// 1. Define the Firestore trigger: runs every time a new document is created 
// in the 'clientApplications' collection.
exports.notifyAdminOfNewApplication = functions.firestore
    .document('clientApplications/{docId}') 
    .onCreate(async (snap, context) => {

        const newAppData = snap.data();
        // Use the 'fullName' field from the new document for the notification body
        const clientName = newAppData.fullName || 'A New Client'; 

        console.log(`New application submitted by: ${clientName}`);

        try {
            // 2. Calculate the number of unread applications (for the badge number)
            const unreadCountSnapshot = await db.collection('clientApplications')
                // Assuming your client sets the default status field to "New"
                .where('status', '==', 'New')
                .get();
            const badgeCount = unreadCountSnapshot.docs.length;

            // 3. Get all admin FCM tokens from the 'adminTokens' collection
            const tokensSnapshot = await db.collection('adminTokens').get();
            if (tokensSnapshot.empty) {
                console.log('No admin tokens found. Notification will not be sent.');
                return null;
            }
            const registrationTokens = tokensSnapshot.docs.map(doc => doc.id);

            // 4. Construct the notification payload (APNs payload is key for iOS badge)
            const payload = {
                notification: {
                    title: '✅ New Application',
                    body: `${clientName} has submitted a new client application.`,
                    sound: 'default' 
                },
                apns: {
                    payload: {
                        aps: {
                            badge: badgeCount 
                        }
                    }
                },
                tokens: registrationTokens // Send to all retrieved tokens
            };

            // 5. Send the notification
            const response = await admin.messaging().sendMulticast(payload);
            
            // Success Log: This is what you will look for in the Firebase Console!
            console.log(`Successfully sent multicast message: ${response.successCount} successes and ${response.failureCount} failures.`);

            return null;

        } catch (error) {
            console.error('FATAL ERROR during notification process:', error);
            return null;
        }
    });
