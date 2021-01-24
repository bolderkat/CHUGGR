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

exports.sendNotificationOnNewBet = functions.firestore
  .document("bets/{docId}")
  .onCreate(async (snap, context) => {
    const newBet = snap.data();
    let betTitle = newBet.title;
    const invitingUser = newBet.acceptedUsers[0];
    const invitingUserDoc = await admin.firestore().doc(`users/${invitingUser}`).get();
    const invitingUserName = invitingUserDoc.get("userName");

    if (newBet.type === "spread") {
      betTitle += `: ${newBet.line}`;
    }

    const invitedUsers = newBet.invitedUsers;
    const userDocPromisesToAwait = [];

    for (const [key, value] of Object.entries(invitedUsers)) {
      userDocPromisesToAwait.push(admin.firestore().doc(`users/${key}`).get());
    }

    const invitedUserDocs = await Promise.all(userDocPromisesToAwait);
    const messagingPromisesToAwait = [];

    for (const userDoc of invitedUserDocs) {
      const user = userDoc.data();
      const fcmTokens = user.fcm;
      if (typeof fcmTokens === 'undefined') continue

      for (const token of fcmTokens) {
        const message = {
          notification: {
            title: `New bet from ${invitingUserName}!`,
            body: betTitle,
          },
          token: token,
          apns: {
            payload: {
              aps: {
                category: "NEW_BET",
                sound: "default"
              }
            }
          }
        }
        messagingPromisesToAwait.push(admin.messaging().send(message));
      }
    }

    await Promise.all(messagingPromisesToAwait);
  });


exports.sendNotificationOnBetClose = functions.firestore
  .document("bets/{docID}")
  .onUpdate(async (change, context) => {
    const oldValue = change.before.data();
    const newValue = change.after.data();
    const isBetClosing = (oldValue.isFinished === false && newValue.isFinished === true);

    if (!isBetClosing) return

    const betTitle = newValue.title;
    const side1Users = newValue.side1Users;
    const side2Users = newValue.side2Users;

    const isWinnerSide1 = (newValue.winner === "one");

    const winners = isWinnerSide1 ? side1Users : side2Users;
    const losers = isWinnerSide1 ? side2Users : side1Users;

    const winnerUserDocPromises = [];
    const loserUserDocPromises = [];

    for (const [key, value] of Object.entries(winners)) {
      winnerUserDocPromises.push(admin.firestore().doc(`users/${key}`).get());
    }

    for (const [key, value] of Object.entries(losers)) {
      loserUserDocPromises.push(admin.firestore().doc(`users/${key}`).get());
    }

    const winnerDocs = await Promise.all(winnerUserDocPromises);
    const loserDocs = await Promise.all(loserUserDocPromises);

    const messagingPromisesToAwait = [];

    for (const userDoc of winnerDocs) {
      const user = userDoc.data();
      const fcmTokens = user.fcm;
      if (typeof fcmTokens === 'undefined') continue

      for (const token of fcmTokens) {
        const message = {
          notification: {
            title: `You won a bet!`,
            body: betTitle,
          },
          token: token,
          apns: {
            payload: {
              aps: {
                category: "BET_WON",
                sound: "default"
              }
            }
          }
        }
        messagingPromisesToAwait.push(admin.messaging().send(message));
      }
    }

    for (const userDoc of loserDocs) {
      const user = userDoc.data();
      const fcmTokens = user.fcm;

      for (const token of fcmTokens) {
        const message = {
          notification: {
            title: `You lost a bet!`,
            body: `You have drinks outstanding for: ${betTitle}`,
          },
          token: token,
          apns: {
            payload: {
              aps: {
                category: "BET_LOST",
                sound: "default"
              }
            }
          }
        }
        messagingPromisesToAwait.push(admin.messaging().send(message));
      }
    }

    await Promise.all(messagingPromisesToAwait);
  });


exports.sendNewFollowerNotification = functions.firestore
  .document("users/{userID}/friends/{friendID}")
  .onCreate(async (snap, context) => {
    const friendUID = context.params.friendID;
    const addingUserID = context.params.userID;
    const friendDoc = await admin.firestore().doc(`users/${friendUID}`).get();
    const addingUserDoc = await admin.firestore().doc(`users/${addingUserID}`).get();

    const friend = friendDoc.data();
    const fcmTokens = friend.fcm;
    if (typeof fcmTokens === 'undefined') return
    const addingUser = addingUserDoc.data();

    const messagingPromisesToAwait = [];

    for (const token of fcmTokens) {
      const message = {
        notification: {
          title: "New follower",
          body: `${addingUser.userName} (${addingUser.firstName} ${addingUser.lastName}) is now following you on CHUGGR. Tap to send them a bet!`,
        },
        token: token,
        apns: {
          payload: {
            aps: {
              category: "NEW_FOLLOWER",
              sound: "default"
            }
          }
        }
      }
      messagingPromisesToAwait.push(admin.messaging().send(message));
    }

    await Promise.all(messagingPromisesToAwait);
  });


exports.sendNewMessageNotification = functions.firestore
  .document("chatRooms/{betID}/actualMessages/{messageID}")
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const body = message.body;
    const senderUserName = message.userName;
    const senderUID = message.uid;

    const betID = context.params.betID;
    const associatedBetDoc = await admin.firestore().doc(`bets/${betID}`).get();
    const associatedBet = associatedBetDoc.data();
    const betTitle = associatedBet.title;

    const acceptedUsers = associatedBet.acceptedUsers;
    const userDocPromisesToAwait = [];

    for (const uid of acceptedUsers) {
      if (uid === senderUID) continue
      userDocPromisesToAwait.push(admin.firestore().doc(`users/${uid}`).get());
    }

    const acceptedUserDocs = await Promise.all(userDocPromisesToAwait);
    const messagingPromisesToAwait = [];

    for (const userDoc of acceptedUserDocs) {
      const user = userDoc.data();
      const fcmTokens = user.fcm;
      if (typeof fcmTokens === 'undefined') continue

      for (const token of fcmTokens) {
        const message = {
          notification: {
            title: `${senderUserName} in ${betTitle}`,
            body: body,
          },
          token: token,
          apns: {
            payload: {
              aps: {
                category: "NEW_MESSAGE",
                sound: "default"
              }
            }
          }
        }
        messagingPromisesToAwait.push(admin.messaging().send(message));
      }
    }

    await Promise.all(messagingPromisesToAwait);
  });

exports.sendOutstandingBetNotification = functions.pubsub.schedule("30 18 * * 5")
  .timeZone("America/Los_Angeles")
  .onRun(async (context) => {
    const snapshot = await admin.firestore().collection("users").get();

    const messagingPromisesToAwait = [];

    snapshot.forEach(doc => {
      const user = doc.data();
      const beers = user.drinksOutstanding.beers;
      const shots = user.drinksOutstanding.shots;
      if (beers > 0 || shots > 0) {
        const fcmTokens = user.fcm;
        if (typeof fcmTokens === 'undefined') return

        for (const token of fcmTokens) {
          const message = {
            notification: {
              title: `Bets outstanding`,
              body: `You owe ${beers} 🍺 ${shots} 🥃 for lost bets. Remember to drink responsibly 😉`,
            },
            token: token,
            apns: {
              payload: {
                aps: {
                  category: "BET_OUTSTANDING",
                  sound: "default"
                }
              }
            }
          }
          messagingPromisesToAwait.push(admin.messaging().send(message));
        }
      }
    });

    await Promise.all(messagingPromisesToAwait);
  });





// TEST Functions

exports.testSendNotificationOnNewBet = functions.firestore
  .document("testBets/{docId}")
  .onCreate(async (snap, context) => {
    const newBet = snap.data();
    let betTitle = newBet.title;
    const invitingUser = newBet.acceptedUsers[0];
    const invitingUserDoc = await admin.firestore().doc(`testUsers/${invitingUser}`).get();
    const invitingUserName = invitingUserDoc.get("userName");

    if (newBet.type === "spread") {
      betTitle += `: ${newBet.line}`;
    }

    const invitedUsers = newBet.invitedUsers;
    const userDocPromisesToAwait = [];

    for (const [key, value] of Object.entries(invitedUsers)) {
      userDocPromisesToAwait.push(admin.firestore().doc(`testUsers/${key}`).get());
    }

    const invitedUserDocs = await Promise.all(userDocPromisesToAwait);
    const messagingPromisesToAwait = [];

    for (const userDoc of invitedUserDocs) {
      const user = userDoc.data();
      const fcmTokens = user.fcm;
      if (typeof fcmTokens === 'undefined') continue

      for (const token of fcmTokens) {
        const message = {
          notification: {
            title: `New bet from ${invitingUserName}!`,
            body: betTitle,
          },
          token: token,
          apns: {
            payload: {
              aps: {
                category: "NEW_BET",
                sound: "default",
                badge: 1
              }
            }
          }
        }
        messagingPromisesToAwait.push(admin.messaging().send(message));
      }
    }

    await Promise.all(messagingPromisesToAwait);
  });


exports.testSendNotificationOnBetClose = functions.firestore
  .document("testBets/{docID}")
  .onUpdate(async (change, context) => {
    const oldValue = change.before.data();
    const newValue = change.after.data();
    const isBetClosing = (oldValue.isFinished === false && newValue.isFinished === true);

    if (!isBetClosing) return

    const betTitle = newValue.title;
    const side1Users = newValue.side1Users;
    const side2Users = newValue.side2Users;

    const isWinnerSide1 = (newValue.winner === "one");

    const winners = isWinnerSide1 ? side1Users : side2Users;
    const losers = isWinnerSide1 ? side2Users : side1Users;

    const winnerUserDocPromises = [];
    const loserUserDocPromises = [];

    for (const [key, value] of Object.entries(winners)) {
      winnerUserDocPromises.push(admin.firestore().doc(`testUsers/${key}`).get());
    }

    for (const [key, value] of Object.entries(losers)) {
      loserUserDocPromises.push(admin.firestore().doc(`testUsers/${key}`).get());
    }

    const winnerDocs = await Promise.all(winnerUserDocPromises);
    const loserDocs = await Promise.all(loserUserDocPromises);

    const messagingPromisesToAwait = [];

    for (const userDoc of winnerDocs) {
      const user = userDoc.data();
      const fcmTokens = user.fcm;
      if (typeof fcmTokens === 'undefined') continue

      for (const token of fcmTokens) {
        const message = {
          notification: {
            title: `You won a bet!`,
            body: betTitle,
          },
          token: token,
          apns: {
            payload: {
              aps: {
                category: "BET_WON",
                sound: "default",
                badge: 1
              }
            }
          }
        }
        messagingPromisesToAwait.push(admin.messaging().send(message));
      }
    }

    for (const userDoc of loserDocs) {
      const user = userDoc.data();
      const fcmTokens = user.fcm;

      for (const token of fcmTokens) {
        const message = {
          notification: {
            title: `You lost a bet!`,
            body: `You have drinks outstanding for: ${betTitle}`,
          },
          token: token,
          apns: {
            payload: {
              aps: {
                category: "BET_LOST",
                sound: "default",
                badge: 1
              }
            }
          }
        }
        messagingPromisesToAwait.push(admin.messaging().send(message));
      }
    }

    await Promise.all(messagingPromisesToAwait);
  });


exports.testSendNewFollowerNotification = functions.firestore
  .document("testUsers/{userID}/friends/{friendID}")
  .onCreate(async (snap, context) => {
    const friendUID = context.params.friendID;
    const addingUserID = context.params.userID;
    const friendDoc = await admin.firestore().doc(`testUsers/${friendUID}`).get();
    const addingUserDoc = await admin.firestore().doc(`testUsers/${addingUserID}`).get();

    const friend = friendDoc.data();
    const fcmTokens = friend.fcm;
    if (typeof fcmTokens === 'undefined') return
    const addingUser = addingUserDoc.data();

    const messagingPromisesToAwait = [];

    for (const token of fcmTokens) {
      const message = {
        notification: {
          title: "New follower",
          body: `${addingUser.userName} (${addingUser.firstName} ${addingUser.lastName}) is now following you on CHUGGR. Tap to send them a bet!`,
        },
        token: token,
        apns: {
          payload: {
            aps: {
              category: "NEW_FOLLOWER",
              sound: "default",
              badge: 1
            }
          }
        }
      }
      messagingPromisesToAwait.push(admin.messaging().send(message));
    }

    await Promise.all(messagingPromisesToAwait);
  });


exports.testSendNewMessageNotification = functions.firestore
  .document("testChatRooms/{betID}/actualMessages/{messageID}")
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const body = message.body;
    const senderUserName = message.userName;
    const senderUID = message.uid;

    const betID = context.params.betID;
    const associatedBetDoc = await admin.firestore().doc(`testBets/${betID}`).get();
    const associatedBet = associatedBetDoc.data();
    const betTitle = associatedBet.title;

    const acceptedUsers = associatedBet.acceptedUsers;
    const userDocPromisesToAwait = [];

    for (const uid of acceptedUsers) {
      if (uid === senderUID) continue
      userDocPromisesToAwait.push(admin.firestore().doc(`testUsers/${uid}`).get());
    }

    const acceptedUserDocs = await Promise.all(userDocPromisesToAwait);
    const messagingPromisesToAwait = [];

    for (const userDoc of acceptedUserDocs) {
      const user = userDoc.data();
      const fcmTokens = user.fcm;
      if (typeof fcmTokens === 'undefined') continue

      for (const token of fcmTokens) {
        const message = {
          notification: {
            title: `${senderUserName} in ${betTitle}`,
            body: body,
          },
          token: token,
          apns: {
            payload: {
              aps: {
                category: "NEW_MESSAGE",
                sound: "default",
                badge: 1
              },
              betID: betID
            }
          }
        }
        messagingPromisesToAwait.push(admin.messaging().send(message));
      }
    }

    await Promise.all(messagingPromisesToAwait);
  });