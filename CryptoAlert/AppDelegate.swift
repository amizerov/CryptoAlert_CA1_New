//
//  AppDelegate.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 27.08.2021.
//

import UIKit
import FirebaseCore
import FirebaseMessaging

var usr = User()
var paraPush = Para()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        ConfigureFirebase(for: application)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    /*func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }*/
}

extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate {

	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		print("AM: willPresent notification")
		completionHandler([.banner, .badge, .sound])
	}
	//func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
    //
    //    let userInfo = response.notification.request.content.userInfo
    //
	//
	//	let para_id = response.notification.request.content.targetContentIdentifier ?? "1014"
	//
	//	paraPush.ID = 111
	//	OpenChartVC(Int(para_id)!)
	//}
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {

        let userInfo = response.notification.request.content.userInfo

        // para_id может приехать как Int (как у тебя сейчас) или как String
        let paraId: Int = {
            if let v = userInfo["para_id"] as? Int { return v }
            if let s = userInfo["para_id"] as? String, let v = Int(s) { return v }

            // если вдруг кто-то пришлёт как "data": { "para_id": ... }
            if let data = userInfo["data"] as? [AnyHashable: Any] {
                if let v = data["para_id"] as? Int { return v }
                if let s = data["para_id"] as? String, let v = Int(s) { return v }
            }

            return 1014 // дефолт на случай отсутствия
        }()

        paraPush.ID = 111
        OpenChartVC(paraId)
    }

	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		completionHandler(.newData)
		print("AM: plase to parse push received")
	}
	
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("AM: FCM token: \(fcmToken!)")
        
        usr.fcmToken = fcmToken!
        usr.uuid = UIDevice.current.identifierForVendor?.uuidString ?? "nil"
        usr.Update()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("AM: APNS Token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Logger) {
        print("AM: Fail to register remote notifications", error)
    }
    
    func ConfigureFirebase(for application: UIApplication) {
        
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
		let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: authOptions, completionHandler: { granted, error in
			if(granted) {
				print("AM: Notification Authorization granted")
			}
			else {
				print("AM: Notification Authorization Error", error as Any)
			}
		})
        
        application.registerForRemoteNotifications()
        print("AM: application registered for remote notifications")
    }
}

func OpenChartVC(_ pid: Int) {
	
	_ = Para(pid) { para in
		DispatchQueue.main.async(execute: {

			opcvc(para)
		})
	}
}

func opcvc(_ p: Para) {
	
	if let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window {
		let stb = UIStoryboard(name: "Main", bundle: nil)
		if	let pedVC = stb.instantiateViewController(withIdentifier: "ParaEditVC") as? ParaEditVC,
			let mainVC = stb.instantiateViewController(withIdentifier: "MainVC") as? MainVC,
			let chartVC = stb.instantiateViewController(withIdentifier: "ChartVC") as? ChartVC {
			
			chartVC.para = p
			
			let navVC = window.rootViewController as? UINavigationController
			
			mainVC.Level = p.Level
			pedVC.thePara = p
			pedVC.mainVC = mainVC

			navVC?.pushViewController(mainVC, animated: false)
			navVC?.pushViewController(pedVC, animated: false)
			navVC?.pushViewController(chartVC, animated: false)
		}
		else {
			WebApi.Log("Error 1 in OpenChartVC(\(p.ID))")
		}
	}
	else {
		WebApi.Log("Error 2 in OpenChartVC(\(p.ID))")
	}
}
