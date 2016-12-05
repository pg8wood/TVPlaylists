//
//  SearchViewController.swift
//  TVPlaylists
//
//  Created by Patrick Gatewood on 12/3/16.
//  Copyright © 2016 Patrick Gatewood. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UISearchResultsUpdating, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Object references to objects created at design time on the storyboard 
    @IBOutlet var resultsTableView: UITableView!
    
    // The application delegate
    var applicationDelegate = UIApplication.shared.delegate as! AppDelegate

    // Used for Search Bar functionality
    var searchResultsController = UISearchController()
    var searchResults = [String]()
    
    // Determines if the filters have been enabled or not
    var filtersSelected = true
    
    // Playlists and shows saved locally on the device
    var localPlaylists = [String]()
    var localShows = [String]()
    
    // String array containing the holidays the user can search for
    var holidays: [String] = ["None", "St. Patrick's Day", "Halloween", "Thanksgiving", "Christmas"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the search results controller
        createSearchResultsController()
        
        // --------------------------
        // Get data from the playlist
        // --------------------------
        
        // Get the String array of playlists
        localPlaylists = applicationDelegate.dict_PlaylistName_MediaName.allKeys as! [String]
        
        // Get a String array of locally-stored shows
        for i in 0 ..< localPlaylists.count {
            
            // Get a list of shows in a playlist
            var showsInPlaylist: [String] = (applicationDelegate.dict_PlaylistName_MediaName[localPlaylists[i]]! as! NSMutableDictionary).allKeys as! [String]
            
            for j in 0 ..< showsInPlaylist.count {
                
                // Add the shows to the String array of names
                if !localShows.contains(showsInPlaylist[j]) {
                    
                    localShows.append(showsInPlaylist[j])
                }
            }
            
        }
        
        filtersSelected = true
         resultsTableView.reloadData()
    }
    
    /*
     ---------------------------------------------
     MARK: - Creation of Search Results Controller
     ---------------------------------------------
     */
    func createSearchResultsController() {
        
        // Create search controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self // Use the same tableView to display results
        let searchBar = searchController.searchBar
        searchBar.sizeToFit()
        
        // Don't dim the background while searching
        searchController.dimsBackgroundDuringPresentation = false
        
        // Add search bar to the navigation bar
        searchBar.placeholder = "Enter a show name"
       
        // Place the search bar
        resultsTableView.tableHeaderView = searchBar
        
        // Store the reference to the SearchController
        searchResultsController = searchController
    }
    
    /*
     -----------------------------------------------
     MARK: - UISearchResultsUpdating Protocol Method
     -----------------------------------------------
     
     This UISearchResultsUpdating protocol required method is automatically called whenever the search
     bar becomes the first responder or changes are made to the text or scope of the search bar.
     You must perform all required filtering and updating operations inside this method.
     */
    func updateSearchResults(for searchController: UISearchController)
    {
        // Empty the searchResults array without keeping its capacity
        searchResults.removeAll(keepingCapacity: false)
        
        // Set searchPredicate to search for any character(s) the user enters into the search bar.
        // [c] indicates that the search is case insensitive.
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        
        // Obtain the shows that contain the character(s) the user types into the Search Bar.
        let localShowsFound = (localShows as NSArray).filtered(using: searchPredicate)
        
        //Obtain the search results as an array of type String
        searchResults = localShowsFound as! [String]
        
        //Reload the table view to display the search results
        resultsTableView.reloadData()
        
        // ------------------------------------------------
        // Collapse filter view while text is being entered
        // ------------------------------------------------
        if filtersSelected {
            resultsTableView.beginUpdates()
            resultsTableView.endUpdates()
        }
    }
    
    /*
     -----------------------------
     MARK: - Search Button Clicked
     -----------------------------
     
     Search the APIs for the entered text using the filters chosen.
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Search online
        
    }
    
    /*
     ----------------------------------------------
     MARK: - UITableViewDataSource Protocol Methods
     ----------------------------------------------
     */
    //----------------------------------------
    // Return Number of Sections in Table View
    //----------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //------------------------------------
    // Return Number of Rows in Table View
    //------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // If there are search results, create count + 1 cells since the first cell is reserved for the search filters
        return searchResults.count >= 1 ? searchResults.count + 1 : 1
    }
    
    //-------------------------------
    // Calculate the height of a cell
    //-------------------------------
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let rowNumber = indexPath.row
        
        if rowNumber == 0 {
            // If the filters row is selected, expand it. Else, collapse it. 
            if filtersSelected {
                filtersSelected = !filtersSelected
                return 300
            } else {
                filtersSelected = !filtersSelected
                return 45
            }
        } else {
            return 100
        }
    }
    
    
    //-------------------------------------
    // Prepare and Return a Table View Cell
    //-------------------------------------
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell {
        
        // Get the row number of the cell
        let rowNumber = indexPath.row
        
        // The first row is the cell containing the search filters; other rows are reserved for results
        var cell: UITableViewCell
        if rowNumber == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "filterCell")!
            
           let thisCell = cell as! SearchFilterTableViewCell
            
            // Set up the filter cell
            thisCell.tableView = tableView
    
            // Set up the button image
            thisCell.showCollapseButton!.setImage(UIImage(named: "downArrow")!, for: UIControlState())
            
        } else {
            
            // Cell is a results data cell. Set it up
            cell = tableView.dequeueReusableCell(withIdentifier: "resultCell")!
            
            // Only display data while searching
            if (searchResultsController.isActive) {
                
                // Show name is index row - 1 since row 0 is reserved for the search filters
                cell.textLabel?.text = searchResults[indexPath.row - 1];
                cell.imageView?.image = UIImage(named: searchResults[indexPath.row - 1])
            }
        }
        
        // Disable selection highlighting for the cells
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    /**
     * -----------------------------------------------
     * MARK: - UIPickerViewDataSource protocol methods
     * -----------------------------------------------
     */
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return holidays.count
    }
    
    /*
     --------------------------------------------
     MARK: - UIPickerViewDelegate Protocol Method
     --------------------------------------------
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return holidays[row]
    }
}
