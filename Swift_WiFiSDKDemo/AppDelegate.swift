//
//  AppDelegate.swift
//  Swift_WiFiSDKDemo
//
//  Created by jie yang on 2020/6/3.
//  Copyright © 2020 jie yang. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var locationManager: CLLocationManager?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.locationManager = CLLocationManager.init()
        self.locationManager?.requestWhenInUseAuthorization()
        self.locationManager?.requestAlwaysAuthorization()
        
        // Override point for customization after application launch.
        self.window?.rootViewController = MainViewController()
        self.window?.backgroundColor = .white;
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

