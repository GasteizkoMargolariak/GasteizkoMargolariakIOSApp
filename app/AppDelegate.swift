// Copyright (C) 2016 Inigo Valentin
//
// This file is part of the Gasteizko Margolariak IOS app.
//
// The Gasteizko Margolariak IOS app is free software: you can
// redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your
// option) any later version.
//
// The Gasteizko Margolariak IOS app is distributed in the
// hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
// Public License for more details.
//
// You should have received a copy of the GNU General Public
// License along with the Gasteizko Margolariak IOS app.
// If not, see <http://www.gnu.org/licenses/>.

import UIKit
import CoreData
import GoogleMaps
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var controller: ViewController?
	var albumController: AlbumViewController?
	var syncController: SyncController?

	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		// Google Mapas API KEY
		GMSServices.provideAPIKey("AIzaSyBfIiBM_YSBlxybmI_Uz_fGoUFN4wacR80")
		
		// Background mode.
		UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
		
		if #available(iOS 10.0, *) {
			let center = UNUserNotificationCenter.current()
			center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
				// Enable or disable features based on authorization.
			}
		} else {
			// Fallback on earlier versions
		}
		
		
		return true
	}
	

	func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		NSLog(":BACKGROUND:LOG: Start bg sync...")
		Notifications()
		Sync()
		
		let when = DispatchTime.now() + 120 // 2 minutes to perform the sync.
		DispatchQueue.main.asyncAfter(deadline: when) {
			completionHandler(UIBackgroundFetchResult.newData)
		}
	}


	/**
	Sent when the application is about to move from active to inactive state.
	This can occur for certain types of temporary interruptions
	(such as an incoming phone call or SMS message) or when the user quits
	the application and it begins the transition to the background state.
	Use this method to pause ongoing tasks, disable timers, and invalidate
	graphics rendering callbacks. Games should use this method to pause the game.
	*/
	func applicationWillResignActive(_ application: UIApplication) {
	}
	

	/**
	Use this method to release shared resources, save user data, invalidate
	timers, and store enough application state information to restore your
	application to its current state in case it is terminated later.
	If your application supports background execution, this method is called
	instead of applicationWillTerminate: when the user quits.
	*/
	func applicationDidEnterBackground(_ application: UIApplication) {
	}

	
	/**
	Called as part of the transition from the background to the active state;
	here you can undo many of the changes made on entering the background.
	*/
	func applicationWillEnterForeground(_ application: UIApplication) {
	}

	
	/**
	Restart any tasks that were paused (or not yet started) while the
	application was inactive. If the application was previously in the background,
	optionally refresh the user interface.
	*/
	func applicationDidBecomeActive(_ application: UIApplication) {
	}

	/**
	Called when the application is about to terminate. Save data if appropriate.
	See also applicationDidEnterBackground:.
	Saves changes in the application's managed object context before the application terminates.
	*/
	func applicationWillTerminate(_ application: UIApplication) {
	}

	// MARK: - Core Data stack
	
	
	// The directory the application uses to store the Core Data store file.
	lazy var applicationDocumentsDirectory: URL = {
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return urls[urls.count-1]
	}()
	
	
	// The managed object model for the application
	lazy var managedObjectModel: NSManagedObjectModel = {
		let modelURL = Bundle.main.url(forResource: "app", withExtension: "momd")!
		return NSManagedObjectModel(contentsOf: modelURL)!
	}()
	
	// he persistent store coordinator for the application
	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
		var failureReason = "There was an error creating or loading the application's saved data."
		do {
			try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
		} catch {
			// Report any error we got.
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
			dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
			
			dict[NSUnderlyingErrorKey] = error as NSError
			let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			NSLog(":DELEGATE:ERROR: Unresolved error \(wrappedError), \(wrappedError.userInfo)")
			abort()
		}
		
		return coordinator
	}()
	
	
	// Returns the managed object context for the application
	lazy var managedObjectContext: NSManagedObjectContext = {
		let coordinator = self.persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()
	
	// MARK: - Core Data Saving support
	
	/**
	Saves the application context.
	*/
	func saveContext () {
		if managedObjectContext.hasChanges {
			do {
				try managedObjectContext.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				NSLog(":DELEGATE:ERROR: Unresolved error \(nserror), \(nserror.userInfo)")
				abort()
			}
		}
	}
}

