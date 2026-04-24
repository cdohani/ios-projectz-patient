//
//  AppDelegate.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 15/02/2024.
//

import UIKit
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager
import GoogleMaps
import GooglePlaces
import FacebookCore
import GoogleSignIn
import UserNotifications
import FirebaseCore
import FirebaseCrashlytics
import FirebaseMessaging
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var pendingDeepLinkURL: URL?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        configureSDKs(application, launchOptions)
        configureFirebaseAndPush(application)
        showSplashScreen()
        handlePendingDeepLinkIfNeeded()

        return true
    }
}

extension AppDelegate {

    func configureSDKs(
        _ application: UIApplication,
        _ launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {

        GMSServices.provideAPIKey("AIzaSyCgh3Dwwdu9IPHbLf-F9hvw0UDc2tqQA94")
        GMSPlacesClient.provideAPIKey("AIzaSyCgh3Dwwdu9IPHbLf-F9hvw0UDc2tqQA94")

        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        //IQKeyboardToolbarManager.shared.toolbarConfiguration.manageBehavior = .byPosition
        UIFont.overrideInitialize()

        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }
}

extension AppDelegate {

    func configureFirebaseAndPush(_ application: UIApplication) {

        
        FirebaseApp.configure()
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        requestNotificationPermission(application)
       
    }

    private func requestNotificationPermission(_ application: UIApplication) {

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }

}
extension AppDelegate {

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        print("📱 APNs token linked to Firebase")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ APNs registration failed:", error.localizedDescription)
    }
}
extension AppDelegate: MessagingDelegate {

    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let token = fcmToken else { return }
        print("🔥 FCM Token (delegate):", token)
        UserDefaults.standard.set(token, forKey: "fcmToken")
        
        if UserDefaults.standard.string(forKey: "authToken") != nil{
            sendDeviceToken(fcmToken: token)
        }
    }
    
    func sendDeviceToken(fcmToken: String){
      
        let param: [String: Any] = [
            "device_token": fcmToken ,
            "device_type": "ios",
            "platform": "ios_patient_app",
        ]
        
        //showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:Constants.URLs.addDeviceToken,completion: { (success) in
            DispatchQueue.main.async {
                
                if success is GeneralResponseModel
                {
                    
                }

            }
        }) { (faliure) in
            DispatchQueue.main.async {
//                self.removeLoadingView()
//                self.showAlertView(message: faliure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
        
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("📩 Notification Payload:", userInfo)
        
        // Safely extract type
        if let type = userInfo["type"] as? String {
            switch type {
            case "doctor":
                // doctor notification
                if let doctorIdString = userInfo["appointment_id"] as? String,
                   let doctorId = Int(doctorIdString) {
                    navigateToDoctorDetail(doctorId: doctorId)
                } else if let doctorId = userInfo["appointment_id"] as? Int {
                    navigateToDoctorDetail(doctorId: doctorId)
                }
                
            case "appointment_booked":
                // appointment notification
                if let bookingType = userInfo["booking_type"] as? String {
                    if let appointmentIdString = userInfo["appointment_id"] as? String,
                       let appointmentId = Int(appointmentIdString) {
                        
                        navigateToAppointmentScreen(appointmentID: appointmentId, bookingType: bookingType,)
                        
                    } else if let appointmentId = userInfo["appointment_id"] as? Int {
                        navigateToAppointmentScreen(appointmentID: appointmentId, bookingType: bookingType)
                    }
                }
                
            default:
                break
            }
        }
        
        completionHandler()
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("📩 Remote notification received:", userInfo)
        completionHandler(.newData)
    }
}
extension AppDelegate {

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {

        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else { return false }

        pendingDeepLinkURL = url
        tryHandlePendingDeepLink()
        return true
    }

    private func handlePendingDeepLinkIfNeeded() {
        if let url = pendingDeepLinkURL {
            handleDeepLink(url: url)
            pendingDeepLinkURL = nil
        }
    }

    private func tryHandlePendingDeepLink() {
        guard let _ = window?.rootViewController as? UINavigationController else {
            return
        }
        handlePendingDeepLinkIfNeeded()
    }

    private func handleDeepLink(url: URL) {
        let components = url.pathComponents
        guard components.count >= 4,
              components[1] == "en",
              let doctorId = Int(components[4]) else { return }
        
        print(doctorId)
        navigateToDoctorDetail(doctorId: doctorId)
    }
}
extension AppDelegate {

    func navigateToDoctorDetail(doctorId: Int) {

        guard let navController = window?.rootViewController as? UINavigationController else {
            print("❌ Root VC not UINavigationController")
            return
        }

        if let topVC = navController.topViewController as? DoctorDetailVC,
           topVC.providerID == doctorId {
            print("ℹ️ Already on doctor detail")
            return
        }

        let vc = UIViewController.getDoctorDetailVC()
        vc.providerID = doctorId
        vc.currentDate = Date()
        navController.pushViewController(vc, animated: true)
    }
    
    func navigateToAppointmentScreen(appointmentID: Int,bookingType:String) {

        guard let navController = window?.rootViewController as? UINavigationController else {
            print("❌ Root VC not UINavigationController")
            return
        }
        if bookingType == "in-person"{
            if let topVC = navController.topViewController as? ApptDoctorDetailVC,
               topVC.appointmentID == appointmentID {
                print("ℹ️ Already on appointment detail")
                return
            }

            let vc = UIViewController.getApptDoctorDetailVC()
            vc.appointmentID = appointmentID
            navController.pushViewController(vc, animated: true)
        }else{
            if let topVC = navController.topViewController as? VideoApptDetailVC,
               topVC.appointmentID == appointmentID {
                print("ℹ️ Already on appointment detail")
                return
            }

            let vc = UIViewController.getVideoApptDetailVC()
            vc.appointmentID = appointmentID
            navController.pushViewController(vc, animated: true)
        }
       
    }
}
extension AppDelegate {

    func showSplashScreen() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController.getSplashVC()
        window?.makeKeyAndVisible()
    }
    func setLandingScreen() { setRootViewController() }
    func setRootViewController() {
        let rootVC: UIViewController = UserDefaults.standard.string(forKey: "authToken") != nil
            ? UIViewController.getDashboardVC()
            : UIViewController.getDashboardVC()

        let nav = UINavigationController(rootViewController: rootVC)
        nav.navigationBar.isHidden = true
        window?.rootViewController = nav
        handlePendingDeepLinkIfNeeded()
    }
}






