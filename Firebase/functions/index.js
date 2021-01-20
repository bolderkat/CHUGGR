const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.sendNotificationOnNewBet = functions.firestore.document("testBets/{docId}").onCreate(async (snap, context) => {
  const newBet = snap.data();
  const betTitle = newBet.title;
  const invitedUsers = newBet.invitedUsers;
  // const invitedUids = Array.from(invitedUsersMap.keys());
  const invitingUser = newBet.acceptedUsers[0];
  const invitingUserDoc = await admin.firestore().doc(`testUsers/${invitingUser}`).get();
  const invitingUserName = invitingUserDoc.get("userName");

  const userDocPromisesToAwait = [];

  for (const [key, value] of Object.entries(invitedUsers)) {
    userDocPromisesToAwait.push(admin.firestore().doc(`testUsers/${key}`).get());
  }

  const invitedUserDocs = await Promise.all(userDocPromisesToAwait);
  const messagingPromisesToAwait = [];

  for (const userDoc of invitedUserDocs) {
    // const fcmTokens = userDoc.get("fcm");
    const user = userDoc.data();
    const fcmTokens = user.fcm;

    for (const token of fcmTokens) {
      const message = {
        notification: {
          title: `New bet from ${invitingUserName}!`,
          body: betTitle,
        },
        token: token,
      }
      messagingPromisesToAwait.push(admin.messaging().send(message));
    }
  }

  const responses = await Promise.all(messagingPromisesToAwait);
  console.log(responses);
});