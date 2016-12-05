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
    
    var dataToPass: [Any] = [0, 0, 0]
    
    
    /*
     -----------------------
     MARK: - View Life Cycle
    ------------------------
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the Edit button the left side of the navigation bar to enable editing of the table view rows
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        // Set up the Add button on the right of the navigation bar to call the addCity method when tapped
        //        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MyMoviesTableViewController.addMovie(_:)))
        //        self.navigationItem.rightBarButtonItem = addButton
        
        // Get the playlists and store them in a String array
        playlists = applicationDelegate.dict_PlaylistName_MediaName.allKeys as! [String]
        
        // Sort the playlists in alphabetical order
        playlists.sort { $0 < $1 }
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
        return playlists.count
    }

    //------------------------------------
    // Return Number of Rows in Table View
    //------------------------------------
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//        // Get the name of the playlist
//        let playlistName: String = playlists[section]
//        
//        // Get the list of movie/shows in the given playlist
//        let mediaInPlaylist: NSMutableDictionary = applicationDelegate.dict_PlaylistName_MediaName[playlistName]! as! NSMutableDictionary
        
        return 1
    }
    
    //-------------------------------------
    // Prepare and Return a Table View Cell
    //-------------------------------------
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath) as! PlayListTableViewCell
        let scrollMenu = cell.scrollMenu!
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
        
        for i in 0 ..< showNamesInPlaylist.count {
            
            // Instantiate a button to be placed within the horizontally scrollable menu
            let scrollMenuButton = UIButton(type: UIButtonType.custom)
            scrollMenuButton.imageView!.contentMode = UIViewContentMode.scaleAspectFit
            
            // Obtain the auto manufacturer's logo image
            let showPosterImage = UIImage(named: showNamesInPlaylist[i])
            
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
            
            // TODO
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
        
        return playlists[section]
    }
    
    /**
     * MARK: - Show button pressed
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
        
        // Get the show data
        let selectedShowData = (applicationDelegate.dict_PlaylistName_MediaName[selectedPlaylist] as! NSMutableDictionary)[selectedShowTitle!]
        
        // Prepare the data to pass
        // dataToPass[0] = playlistName
        // dataToPass[1] = showName
        // dataToPass[2] = selectedShowData
        dataToPass[0] = selectedPlaylist
        dataToPass[1] = selectedShowTitle!
        dataToPass[2] = selectedShowData!

        performSegue(withIdentifier: "showEpisodes", sender: self)
    }
    
    /**
     * MARK: - Search Button tapped
     */
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showSearch", sender: self)
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

}