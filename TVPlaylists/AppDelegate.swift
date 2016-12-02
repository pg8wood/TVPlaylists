//
//  AppDelegate.swift
//  TVPlaylists
//
//  Created by Patrick Gatewood on 11/25/16.
//  Copyright © 2016 Patrick Gatewood. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // Dictionary object whose contents are modified at runtime
    var dict_PlaylistName_MediaName: NSMutableDictionary = NSMutableDictionary()

    
    /*
     -----------------------------
     MARK: - Read the Dictionaries
     -----------------------------
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Get the path to the mutable dictionary that stores the plist containing the user's playlists
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectoryPath = paths[0] as String
        
        // Get a reference to the plist
        let playlistPlistFileInDocumentDirectory = documentDirectoryPath + "/MyMedia.plist"
        
        // Initialize an NSMutableDictionary with the contents of the plist file
        let mediaDictionaryFromFile: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: playlistPlistFileInDocumentDirectory)
        
        // ----------------------------
        // Load the playlist dictionary
        // ----------------------------
        
        // If the optional has a value, the file exists in the Documents directory. Else, read from the plist in the app's main bundle.
        if let playlistDictonaryFromFileInDocumentDirectory = mediaDictionaryFromFile {
            
            // MyMedia.plist already exists in the Docunent directory
            dict_PlaylistName_MediaName = playlistDictonaryFromFileInDocumentDirectory
        } else {
            
            // MyMedia.plist does not exist in the Documents directory: read from the app's main bundle. 
            let mediaPlistFileInMainBundle = Bundle.main.path(forResource: "MyMedia", ofType: "plist")
            
            // Load the contents of the plist file into an NSMutableDictonary object.
            let mediaDictonaryFromFileInMainBundle: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: mediaPlistFileInMainBundle!)
            dict_PlaylistName_MediaName = mediaDictonaryFromFileInMainBundle!
        }
        
        return true
    }

    /*
     ----------------------------
     MARK: - Write the Dictionary
     ----------------------------
     */
    func applicationWillResignActive(_ application: UIApplication) {
       // Get the file path to MyMedia.plist
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectoryPath = paths[0] as String
        let mediaPlistFilePathInDocumentDirectory = documentDirectoryPath + "/MyMedia.plist"
        
        // Write the changes to the plist file
        dict_PlaylistName_MediaName.write(toFile: mediaPlistFilePathInDocumentDirectory, atomically: true)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

