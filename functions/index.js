// /functions/index.js (V2 Syntax)

// Import V2 functions modules
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require('firebase-admin');

// Initialize Admin SDK explicitly for the current project
// This setup is stable and works with V2 deployment
admin.initializeApp({
    projectId: process.env.GCLOUD_PROJECT
});

const db = admin.firestore();

// 1. Define the Firestore trigger using V2 syntax
exports.notifyAdminOfNewApplication = onDocumentCreated(
    // Resource Path
    "clientApplications/{docId}", 
    async (event) => {

        // Check if the document data exists
        if (!event.data) {
            console.log("No data found in document event.");
            return null;
        }

        const newAppData = event.data.data();
        const clientName = newAppData.fullName || 'A New Client'; 

        console.log(`New application submitted by: ${clientName}`);

        try {
            // 2. Calculate the number of unread applications (for the badge number)
            const unreadCountSnapshot = await db.collection('clientApplications')
                .where('status', '==', 'New')
                .get();
            const badgeCount = unreadCountSnapshot.docs.length;

            // 3. Get all admin FCM tokens
            const tokensSnapshot = await db.collection('adminTokens').get();
            if (tokensSnapshot.empty) {
                console.log('No admin tokens found. Notification will not be sent.');
                return null;
            }
            const registrationTokens = tokensSnapshot.docs.map(doc => doc.id);

            // 4. Construct the notification payload (using the V2 structure, similar to V1)
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
                tokens: registrationTokens // sendAll is now the standard way
            };

            // 5. Send the notification using the stable sendAll method
            const response = await admin.messaging().sendAll([payload]);
            
            // Success Log: This is what you will look for in the Firebase Console!
            console.log(`Successfully sent multicast message: ${response.successCount} successes and ${response.failureCount} failures.`);

            return null;

        } catch (error) {
            console.error('FATAL ERROR during notification process:', error);
            return null;
        }
    }
);
