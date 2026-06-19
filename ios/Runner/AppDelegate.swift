import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // ── Firebase ───────────────────────────────────────────────────────
        FirebaseApp.configure()

        // ── APNs delegate – lets FirebaseMessaging intercept tokens ────────
        Messaging.messaging().delegate = self

        // ── Request APNs authorisation (alert, badge, sound) ──────────────
        // The actual OS dialog is shown by Flutter via firebase_messaging's
        // requestPermission() call in FCMService.requestPermission().
        // We register here so APNs tokens are always forwarded to FCM even
        // when the Flutter side hasn't shown the dialog yet.
        UNUserNotificationCenter.current().delegate = self

        application.registerForRemoteNotifications()

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // ── APNs device token → forward to FCM ─────────────────────────────────
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    // ── APNs registration failed (log only, don't crash) ───────────────────
    override func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("⚠️ APNs registration failed: \(error.localizedDescription)")
    }

    // ── Foreground presentation: show banner even when app is in foreground ─
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Flutter's firebase_messaging handles display; passing .banner + .sound
        // ensures the notification is still visible when the app is open.
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .badge, .sound])
        } else {
            completionHandler([.alert, .badge, .sound])
        }
    }
}

// ── MessagingDelegate – logs the FCM token (Flutter plugin manages the rest) ──
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("📱 FCM token: \(fcmToken ?? "nil")")
        // The Flutter firebase_messaging plugin picks this up automatically.
    }
}
