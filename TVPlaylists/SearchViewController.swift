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
    var localSearchResults = [String]()
    var webSearchResults = [String]()
    
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
        
        // Hide the first TableView section header
        //resultsTableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0);
        
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
        // Empty the localSearchResults array without keeping its capacity
        localSearchResults.removeAll(keepingCapacity: false)
        
        // Set searchPredicate to search for any character(s) the user enters into the search bar.
        // [c] indicates that the search is case insensitive.
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        
        // Obtain the shows that contain the character(s) the user types into the Search Bar.
        let localShowsFound = (localShows as NSArray).filtered(using: searchPredicate)
        
        //Obtain the search results as an array of type String
        localSearchResults = localShowsFound as! [String]
        
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
        return 3
    }
    
    // Set the title of the TableView section header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // Section 0 is reserved for the filter cell
        if section == 0 {
            return nil
        }
        else if section == 1 {
            return searchResultsController.isActive ? "On Device" : nil
        } else {
            return searchResultsController.isActive ? "On the Web" : nil
        }
    }
    
    // Set the height of the TableView section header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0.1
        } else {
            return searchResultsController.isActive ? 32.0 : 0.1
        }
    }
    
    //------------------------------------
    // Return Number of Rows in Table View
    //------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return localSearchResults.count
        } else {
            return webSearchResults.count
        }
    }
    
    //-------------------------------
    // Calculate the height of a cell
    //-------------------------------
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let rowNumber = indexPath.row
        let sectionNumber = indexPath.section
        
        if rowNumber == 0 && sectionNumber == 0 {
            // If the filters row is selected, expand it. Else, collapse it. 
            if filtersSelected {
                filtersSelected = !filtersSelected
                return 300
            } else {
                filtersSelected = !filtersSelected
                return 37
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
        let sectionNumber = indexPath.section
        
        // The first row is the cell containing the search filters; other rows are reserved for results
        var cell: UITableViewCell
        if sectionNumber == 0 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "filterCell")!
            
            // Section 0, row 0 is reserved for the search filtering cell
            if rowNumber == 0 {
        
                let thisCell = cell as! SearchFilterTableViewCell
                
                // Set up the filter cell
                thisCell.tableView = tableView
                
                // Set up the button image
                thisCell.showCollapseButton!.setImage(UIImage(named: "downArrow")!, for: UIControlState())
            }
        }
        else if sectionNumber == 1 {
            
            // Cell is a local results data cell
            cell = tableView.dequeueReusableCell(withIdentifier: "resultCell")!
            
            // Only display data while searching
            if (searchResultsController.isActive) {
                
                let result = localSearchResults[indexPath.row]
                
                cell.textLabel?.text = result
                cell.imageView?.image = UIImage(named: result)
            }
        }
        else {
            // Cell is a web results data cell
            cell = tableView.dequeueReusableCell(withIdentifier: "resultCell")!
            
            // TODO populate cell with data
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
