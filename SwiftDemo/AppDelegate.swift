//
//  AppDelegate.swift
//  Swi1ftDemo
//
//  Created by i-Mobilize on 17/08/14.
//  Copyright (c) 2014 i-Mobilize. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?


    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
      
        GlobalVariableSharedInstance.initLocationManager()
        
        Parse.setApplicationId("BOSc5zPhDqIoi3yTALoTk0f7SgEvG1LFOvyiyt1T", clientKey: "gFuQ9F6tJMMQvHYi88WkG8jXUqhWjgBUJpBXE3B9")
        
        let googleMapsApiKey = "AIzaSyA7DsUQjh17xnwBQFpSXO57a6HZV7MhhYs"
        
        GMSServices.provideAPIKey(googleMapsApiKey)
        
//    [FBLoginView class];

        PFFacebookUtils.initializeFacebook()
        
        
//        println(UIDevice.currentDevice().model)
        let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        application.setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        return true
    }

    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func application(application: UIApplication!, openURL url: NSURL!, sourceApplication: String!, annotation: AnyObject!) -> Bool
    {
//        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication, withSession: PFFacebookUtils.session())
//        return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
    }
    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        let user = PFUser.currentUser() as PFUser!
        let installation = PFInstallation.currentInstallation()
        if (user != nil)    //if (self.facebookLogin == true)//if (FBSession.activeSession().isOpen)
        {
            
            installation["username"] = user.username
            installation["userId"] = user.objectId
            installation.channels = ["Global", NSString(string: "A\(user.objectId)")];
        }
        else {
            
            installation.channels = ["Global"];
            
        }
        installation.saveInBackground()
        
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        let installation = PFInstallation.currentInstallation()
        if(installation != nil){
            installation.channels = ["Global"];
            installation.saveInBackground()
        }
    }

    func applicationDidBecomeActive(application: UIApplication!) {
//       FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
        FBAppEvents.activateApp()
        
    }

    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        PFPush.handlePush(userInfo)
    }
}

