//
//  FirebaseSwiftUiApp.swift
//  CareerTracker
//
//  Created by Yi Ling on 5/2/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      let providerFactory = AppCheckDebugProviderFactory()
      AppCheck.setAppCheckProviderFactory(providerFactory)

      FirebaseApp.configure()

    return true
  }
}

@main
struct FirebaseSwiftUIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            TopView()
        }
    }
}
