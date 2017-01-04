//
//  MyMediaTableViewController.swift
//  TVPlaylists
//
//  Created by Patrick Gatewood on 11/25/16.
//  Copyright © 2016 Patrick Gatewood. All rights reserved.
//

import UIKit

class MyMediaTableViewController: UITableViewController {

    // Object reference to the UITableView objects created in the Interface Builder
    @IBOutlet var mediaTableView: UITableView!
    
    // The height of the ScrollView
    let kScrollMenuHeight: CGFloat = 150.0
    
    let applicationDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Create and initialize arrays
    var playlists = [String]()
    var shows = [String]()
    
    // A playlist up for deletion
    var playlistToDelete: String = ""
    var showToDelete: String = ""
    
    var dataToPass: [Any] = [0, 0, 0, 0]
    
    
    /*
     -----------------------
     MARK: - View Life Cycle
    ------------------------
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the Edit button the left side of the navigation bar to enable editing of the table view rows
        //self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        let editButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(MyMediaTableViewController.editButtonTapped(_:)))
        self.navigationItem.leftBarButtonItem = editButton
      
        
        // Get the playlists and store them in a String array
        playlists = applicationDelegate.dict_PlaylistName_MediaName.allKeys as! [String]
        
        // Sort the playlists in alphabetical order
        playlists.sort { $0 < $1 }
    }
    
    // Called right before the view will appear
    override func viewWillAppear(_ animated: Bool) {
    
        // Reload the data
        playlists = applicationDelegate.dict_PlaylistName_MediaName.allKeys as! [String]
        playlists.sort { $0 < $1}
        mediaTableView.reloadData()
    }

   
    /*
     ----------------------------------------------
     MARK: - UITableViewDataSource Protocol Methods
     ----------------------------------------------
     */
    
    //----------------------------------------
    // Return Number of Sections in Table View
    //----------------------------------------
    override func numberOfSections(in tableView: UITableView) -> Int {
        return playlists.count > 0 ? playlists.count : 1
    }

    //------------------------------------
    // Return Number of Rows in Table View
    //------------------------------------
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //-------------------------------------
    // Prepare and Return a Table View Cell
    //-------------------------------------
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath) as! PlayListTableViewCell
        
        // If no playlists were found, alert the user
        if playlists.count == 0 {
            cell.errorLabel!.text = "No playlists found! Tap 'Edit' and '+' to add a new playlist."
            cell.errorLabel!.textColor = UIColor.white
            
            // Hide the scrollMenu and its subviews 
            cell.scrollMenu.removeFromSuperview()
            return cell
        } else {
            cell.errorLabel!.text! = ""
        }
        
        let scrollMenu = cell.scrollMenu!
        
        // Remove any preexisting buttons from the scrollview
        let scrollSubviews = scrollMenu.subviews
        for subview in scrollSubviews {
            subview.removeFromSuperview()
        }
        
        // Remove any preexisting text from the cell
        cell.textLabel!.text = ""
        
        let sectionNumber: Int = (indexPath as NSIndexPath).section
        
        // Get the name of the playlist
        let playlistName: String = playlists[sectionNumber]
        
        // Get the list of movie/shows in the given playlist
        let mediaInPlaylist: NSMutableDictionary = applicationDelegate.dict_PlaylistName_MediaName[playlistName]! as! NSMutableDictionary
        
        let showNamesInPlaylist = mediaInPlaylist.allKeys as! [String]
        
        // ----------------------------------------------------------------------
        // Instantiate and setup the buttons for the horizontally scrollable menu
        // ----------------------------------------------------------------------
        
        // Instantiate a mutable array to hold the menu buttons to be created
        var listOfMenuButtons = [UIButton]()
        
        // Show a hint message in an empty cell
        if showNamesInPlaylist.count == 0 {
            cell.textLabel!.numberOfLines = 3
            cell.textLabel!.lineBreakMode = .byWordWrapping
            cell.textLabel!.textColor = UIColor.white
            
            cell.textLabel!.text = "No content found. To add episodes to a playlist, search for a show and add the episodes you like."
        }
        
        for i in 0 ..< showNamesInPlaylist.count {
            
            // Instantiate a button to be placed within the horizontally scrollable menu
            let scrollMenuButton = UIButton(type: UIButtonType.custom)
            scrollMenuButton.imageView!.contentMode = UIViewContentMode.scaleAspectFit
            
            // Obtain the show's poster image
            var showPosterImage: UIImage!
            
            let imageInXcAssets = UIImage(named: showNamesInPlaylist[i])
        
            // Image found in xcassetsFolder
            if imageInXcAssets != nil {
                showPosterImage = imageInXcAssets
            } else {
                
                // Image is in the Documents directory
                showPosterImage = loadImageFromDocumentsDirectory(imageName: showNamesInPlaylist[i])
            }
            
            // Set the button frame at origin at (x, y) = (0, 0) with
            // button width  = poster image + 10 points padding for each side
            // button height = kScrollMenuHeight points
            let imageWidth: CGFloat = 80.0
            
            scrollMenuButton.setTitle(showNamesInPlaylist[i], for: UIControlState())
            
            scrollMenuButton.frame = CGRect(x: 0.0, y: 0.0, width: imageWidth + 20.0, height: kScrollMenuHeight)
            
            // Set the button image to be the auto maker's logo
            scrollMenuButton.setImage(showPosterImage, for: UIControlState())
            
            // Calculate the width of the button
            let buttonWidth: CGFloat = imageWidth + 30.0
            
            // Set the button frame with width=buttonWidth height=kScrollMenuHeight points with origin at (x, y) = (0, 0)
            scrollMenuButton.frame = CGRect(x: 0.0, y: 0.0, width: buttonWidth, height: kScrollMenuHeight)
            
            // Set the button to invoke the buttonPressed: method when the user taps it
            scrollMenuButton.addTarget(self, action: #selector(MyMediaTableViewController.showButtonPressed(_:)), for: .touchUpInside)
            
            // Add the constructed button to the list of buttons
            listOfMenuButtons.append(scrollMenuButton)
        }
        
        // ----------------------------------------------------------------------------------------------
        // Compute the sumOfButtonWidths = sum of the widths of all buttons to be displayed in the menu
        // ----------------------------------------------------------------------------------------------
        
        var sumOfButtonWidths: CGFloat = 0.0
        
        for j in 0 ..< listOfMenuButtons.count {
            
            // Obtain the obj ref to the jth button in the listOfMenuButtons array
            let button: UIButton = listOfMenuButtons[j]
            
            // Set the button's frame to buttonRect
            var buttonRect: CGRect = button.frame
            
            // Set the buttonRect's x coordinate value to sumOfButtonWidths
            buttonRect.origin.x = sumOfButtonWidths
            
            // Set the button's frame to the newly specified buttonRect
            button.frame = buttonRect
            
            // Add the button to the horizontally scrollable menu
            scrollMenu.addSubview(button)
            
            // Add the width of the button to the total width
            sumOfButtonWidths += button.frame.size.width
        }
        
        // Horizontally scrollable menu's content width size = the sum of the widths of all of the buttons
        // Horizontally scrollable menu's content height size = 1 to disable vertical scrolling
        scrollMenu.contentSize = CGSize(width: sumOfButtonWidths, height: 1)

        
        //let imageName = showNamesInPlaylist[rowNumber]
        //cell.imageView!.image = UIImage(named: imageName)!
        
        return cell
    }
    
    // Format the headerView and its label
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = UIColor.white
        headerView.backgroundView!.backgroundColor = UIColor.clear
    }
    
    
    //-----------------------------
    // Set Title for Section Header
    //-----------------------------
    
    // Set the table view section header to be the country name
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        
        return playlists.count > 0 ? playlists[section] : ""
    }
    
    /**
     * ---------------------------
     * MARK: - Show button pressed
     * ---------------------------
     */
    func showButtonPressed(_ sender: UIButton) {
        
        let selectedShowTitle = sender.title(for: UIControlState())
        
        // ---------------------------------------------------------
        // Determine which playlist the selected button is a part of
        // ---------------------------------------------------------
        let button = sender 
        let superView = button.superview!
        let buttonCell = superView.superview?.superview! as! PlayListTableViewCell
        let indexPath = mediaTableView.indexPath(for: buttonCell)
        let selectedSection = indexPath!.section
        let selectedPlaylist = playlists[selectedSection]
        playlistToDelete = selectedPlaylist
        showToDelete = selectedShowTitle!
        
        // Get the show data
        let selectedShowData = (applicationDelegate.dict_PlaylistName_MediaName[selectedPlaylist] as! NSMutableDictionary)[selectedShowTitle!]
        
        // Prepare the data to pass
        // dataToPass[0] = playlistName
        // dataToPass[1] = showName
        // dataToPass[2] = selectedShowData
        dataToPass[0] = selectedPlaylist
        dataToPass[1] = selectedShowTitle!
        dataToPass[2] = selectedShowData!
        
        if mediaTableView.isEditing {
            showDeleteWarningMessage("Are you you would like to delete \(selectedShowTitle!) and all of its episodes?", type: "Show")
        } else {
            performSegue(withIdentifier: "showEpisodes", sender: self)
        }
    }
    
    /**
     * MARK: - Search Button tapped
     */
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showSearch", sender: self)
    }
    
    /**
     * MARK: - Edit Button tapped
     */
    func editButtonTapped(_ sender: UIBarButtonItem) {
        
        
        // Change the search icon into a + icon to allow the user to add a new playlist
        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MyMediaTableViewController.addPlaylist(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        
        // Set the edit button to the done button
        let doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(MyMediaTableViewController.donebuttonTapped(_:)))
        self.navigationItem.leftBarButtonItem = doneButton
        
        // Only allow the editing of cells if at least one playlist is displayed
        if playlists.count > 0 {
            // Allow playlists to be delted
            mediaTableView.isEditing = true
        }
    }
    
    /**
     * MARK: - Done Button tapped
     */
    func donebuttonTapped(_ sender: UIBarButtonItem) {
        
        // Set the buttons back to their original values
        let editButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(MyMediaTableViewController.editButtonTapped(_:)))
        self.navigationItem.leftBarButtonItem = editButton
        let searchButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(MyMediaTableViewController.searchButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem = searchButton
        mediaTableView.isEditing = false
    }
    
    /**
     * MARK: - Add Button tapped
     */
    func addPlaylist(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "showAddPlaylist", sender: self)
    }
    
    //---------------------
    // Delete Button Tapped
    //---------------------
    
    // This is the method invoked when the user taps the Delete button in the Edit mode
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {   // Handle the Delete action
            
            // Obtain the playlist to be deleted
            playlistToDelete = playlists[(indexPath as NSIndexPath).section]
            
            showDeleteWarningMessage("Warning: This will delete the entire playlist and its contents. Are you sure?", type: "Playlist")
        }
    }
    
    // Disable swipe to delete unless the user is in Edit mode 
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
            return .delete
        }
        
        return .none
    }
    
    
    /**
     * MARK: - Load image from Documents directory
     */
    func loadImageFromDocumentsDirectory(imageName: String) -> UIImage {
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectoryPath = paths[0] as String
        let imagePath = documentDirectoryPath + "/\(imageName)"
        
        if fileManager.fileExists(atPath: imagePath) {
            return UIImage(contentsOfFile: imagePath)!
        } else {
            
            // Image not found
            return UIImage(named: "noPosterImage")!
        }
    }
    
    
    /**
     * MARK: - Prepare for segue
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showEpisodes" {
            
            // Pass the data to the downstream ViewController
            let episodesViewController: EpisodesViewController = segue.destination as! EpisodesViewController
            episodesViewController.dataPassed = dataToPass
        }
    }
    
    /*
     ----------------------------------------------
     MARK: - Unwind Segue Method
     ----------------------------------------------
     */
    @IBAction func unwindToMyTheatresViewController(segue: UIStoryboardSegue) {
        
        if segue.identifier == "addPlaylist-Save" {
            // Obtain object reference to the source view controller
            let controller: AddPlaylistViewController = segue.source as! AddPlaylistViewController
            
            let playlistNameEntered: String = controller.playlistNameTextField!.text!
            
            // Save the new playlist
            playlists.append(playlistNameEntered)
            applicationDelegate.dict_PlaylistName_MediaName.setValue(NSMutableDictionary(), forKey: playlistNameEntered)
            
            // Set the buttons back to their original values
            let editButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(MyMediaTableViewController.editButtonTapped(_:)))
            self.navigationItem.leftBarButtonItem = editButton
            let searchButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(MyMediaTableViewController.searchButtonTapped(_:)))
            self.navigationItem.rightBarButtonItem = searchButton
            mediaTableView.isEditing = false
        }
        
        // Reload the data
        playlists.sort { $0 < $1}
        mediaTableView.reloadData()
    }
    
    /*
     ----------------------------------
     MARK: - Share Action Button Tapped
     ----------------------------------
     */
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        
        // Ask the user which playlist they would like to share
        
        // Create an alert controller
        let alertController = UIAlertController(title: "Share Playlsit", message: "Which playlist would you like to share?", preferredStyle: UIAlertControllerStyle.alert)
        
        // Add an option for each playlist
        for playlistName in playlists {
            alertController.addAction(UIAlertAction(title: playlistName, style: UIAlertActionStyle.default, handler: sharePlaylist))
        }
        
        // Add a cancel option
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        // Present the alert controller to the user
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Opens a PopOverPresentationController so the user may share the playlist with a service of their choice
    func sharePlaylist(alert: UIAlertAction!) {
        
        // Get the playlist to share
        let playlistName = alert.title!
        var playlistString = "Playlist: " + playlistName + "\n"
        
        // Get info about the playlist chosen 
        let playlistToShare: NSMutableDictionary = applicationDelegate.dict_PlaylistName_MediaName[playlistName] as! NSMutableDictionary
        let showsInPlaylist: [String] = playlistToShare.allKeys as! [String]
        
        // Create a String representation of the playlist
        for i in 0 ..< showsInPlaylist.count {
            
            playlistString.append("\n\t" + showsInPlaylist[i])
            
            let showSeasons: NSMutableDictionary = playlistToShare[showsInPlaylist[i]] as! NSMutableDictionary
            var savedSeasons = [String]()
            savedSeasons = showSeasons.allKeys as! [String]
            savedSeasons.sort { $0 < $1 }
            
            for j in 0 ..< savedSeasons.count {
                
                playlistString.append("\n\t\t Season " + savedSeasons[j])
                let episodesInSeason: [Any] = showSeasons[savedSeasons[j]] as! [Any]
                
                for k in 0 ..< episodesInSeason.count {
                    
                    let episodeName = (episodesInSeason[k] as! [Any])[0]
                    playlistString.append("\n\t\t\t" + (episodeName as! String))
                }
            }
            
            playlistString.append("\n")
        }
        
        let dataToShare: [String] = [playlistString]
        
        let activityViewController: UIActivityViewController = UIActivityViewController.init(activityItems: dataToShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToFacebook]
        
        //activityViewController.popoverPresentationController?.barButtonItem = sender
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    /*
     ----------------------------
     MARK: - Show Warning Message
     ----------------------------
     */
    func showDeleteWarningMessage(_ message: String, type: String) {
        
        /*
         Create a UIAlertController object; dress it up with title, message, and preferred style;
         and store its object reference into local constant alertController
         */
        let alertController = UIAlertController(title: "", message: message,
                                                preferredStyle: UIAlertControllerStyle.alert)
        
        // Create a UIAlertAction object and add it to the alert controller
        if type == "Playlist" {
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: handlePlaylistYesTap))
        } else if type == "Show" {
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: handleShowYesTap))
        }
        alertController.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        
        // Present the alert controller by calling the present method
        present(alertController, animated: true, completion: nil)
    }
    
    // User tapped yes in alert handler when deleting a playlist
    func handlePlaylistYesTap(alert: UIAlertAction!) {
        
        // Remove the entire playlist from the dictionary
        applicationDelegate.dict_PlaylistName_MediaName.removeObject(forKey: playlistToDelete)
        
        // Reload the data
        playlists = applicationDelegate.dict_PlaylistName_MediaName.allKeys as! [String]
        playlists.sort { $0 < $1 }
        
        mediaTableView.reloadData()
    }
    
    // User tapped yes in alert handler when deleting a show
    func handleShowYesTap(alert: UIAlertAction!) {
        
        // Remove the entire show from the dictionary
        (applicationDelegate.dict_PlaylistName_MediaName[playlistToDelete] as! NSMutableDictionary).removeObject(forKey: showToDelete)
        
        // Reload the data
        playlists = applicationDelegate.dict_PlaylistName_MediaName.allKeys as! [String]
        playlists.sort { $0 < $1 }
        
        mediaTableView.reloadData()
    }

}
