//
//  SearchViewController.swift
//  TVPlaylists
//
//  Created by Patrick Gatewood on 12/3/16.
//  Copyright © 2016 Patrick Gatewood. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UISearchResultsUpdating, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // Object references to objects created at design time on the storyboard 
    @IBOutlet var resultsTableView: UITableView!
    
    // The application delegate
    var applicationDelegate = UIApplication.shared.delegate as! AppDelegate

    // Used for Search Bar functionality
    var searchResultsController = UISearchController()
    var localSearchResults = [String]()
    
    // Instance variables
    var listOfShowsFound = [AnyObject]()
    var arrayOfShowDictionaries = [AnyObject]()
    var numberOfShowsToDisplay = 0
    
    // Determines if the filters have been enabled or not
    var filtersSelected = true
    
    // Playlists and shows saved locally on the device
    var localPlaylists = [String]()
    var localShows = [String]()
    
    // Data to be passed to a downstream view controller
    var dataToPass: [Any] = [0, 0, 0, 0]
    var filtersToPass: [String] = ["", "", ""]
    
    // My TMDB API Key
    let tmdbApiKey: String = "68060180bf3305a501c36e9a7ca5f03c"
    
    // String array containing the holidays the user can search for
    var holidays: [String] = ["None", "St. Patrick's Day", "Halloween", "Thanksgiving", "Christmas"]
    var chosenHoliday: String = "None"
    
    /*
     * -----------------------
     * MARK: - View Life Cycle
     * -----------------------
     */
    
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
        
        // Set the SearchBar's delegate to be this ViewController
        searchBar.delegate = self
        
        // Close the keyboard if the user taps anywhere outside a text field.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
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
        
        // Discard old search results
        arrayOfShowDictionaries.removeAll(keepingCapacity: false)
        
        var dictionaryOfShowsFound = [String: AnyObject]()
        
        // Since a URL cannot have spaces, replace each space in the movie name to search with +.
        let showNameToSearch = searchBar.text!.replacingOccurrences(of: " ", with: "+", options: [], range: nil)
        
        // Search The show DB API to search for the entered query
        // This URL returns the JSON data of the shows found for the search query showNameToSearch as in STEP 1
        let apiURL = "http://api.themoviedb.org/3/search/tv?api_key=\(tmdbApiKey)&language=en-US&query=\(showNameToSearch)"
        
        // Create a URL object from the API URL string
        let url = URL(string: apiURL)
        
        var jsonError: NSError?
        
        // TODO: if slow, try using a NSURL session if this yields poor performance.
        // To obtain the best performance:
        // (1) Download data in multiple threads including background downloads using multithreading and Grand Central Dispatch.
        // (2) Store each image on the device after first download to prevent downloading it repeatedly.
        
        // Download the JSON via HTTP in a single thread.
        let jsonData: Data?
        do {
            jsonData = try Data(contentsOf: url!, options: NSData.ReadingOptions.dataReadingMapped)
            
        } catch let error as NSError {
            jsonError = error
            jsonData = nil
        }
        
        if let jsonDataFromApiUrl = jsonData {
            
            // JSON data is successfully retrieved
            
            do {
                let jsonDataDictionary = try JSONSerialization.jsonObject(with: jsonDataFromApiUrl, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                
                // Typecast the returned NSDictionary as Dictionary<String, AnyObject>
                dictionaryOfShowsFound = jsonDataDictionary as! Dictionary<String, AnyObject>
                
                // listOfShowsFound is an Array of Dictionaries, where each Dictionary contains data about a show
                listOfShowsFound = dictionaryOfShowsFound["results"] as! Array<AnyObject>
                
                let numberOfshowsFromJsonData = listOfShowsFound.count
                
                // No results were found
                if numberOfshowsFromJsonData < 1 {
                    
                    showNoResultsFound(rowNumber: 0)
                    return
                }
                
                // Select no more than 50 shows to display using the Ternary Conditional Operator
                numberOfShowsToDisplay = numberOfshowsFromJsonData > 50 ? 50 : numberOfshowsFromJsonData
                
                // Declaration of local variables
                var posterImageURL: String?
                var showTitle: String?
                var showId: String
                var releaseDate: String?
                var mpaaRating: String?
                var imdbRating: String?
                var runtime: String?
                var actors: String?
                
                
                for j in 0..<numberOfShowsToDisplay {
                    
                    let showDictionary = listOfShowsFound[j] as! Dictionary<String, AnyObject>
                    
                    //-----------------
                    // Poster Image URL
                    //-----------------
                    
                    /*
                     The poster path is given in the following form in the JSON file:
                     {"poster_path":"\/xfWac8MTYDxujaxgPVcRD9yZaul.jpg", ...}
                     
                     The \ character must be replaced with http://image.tmdb.org/t/p/w185/ where w185 specifies the image size.
                     
                     The poster sizes can be specified as: "w92", "w154", "w185", "w342", "w500", "w780", or "original".
                     The original size is about 1000x1500.
                     */
                    
                    let posterImageFilenameFromJson: AnyObject? = showDictionary["poster_path"]
                    
                    if var posterImageFilename = posterImageFilenameFromJson as? String {
                        
                        if !posterImageFilename.isEmpty && posterImageFilename != "<null>" {
                            
                            // Delete the first \ character
                            posterImageFilename.remove(at: posterImageFilename.startIndex)
                            
                            // Add the first part of the URL with image size w185
                            posterImageURL = "http://image.tmdb.org/t/p/w185/" + posterImageFilename
                            
                        } else {
                            posterImageURL = "unavailable"
                        }
                        
                    } else {
                        posterImageURL = "unavailable"
                    }
                    
                    //------------
                    // Show Title
                    //------------
                    
                    let showTitleFromJson: String? = showDictionary["name"] as! String?
                    
                    if let showTitleObtained = showTitleFromJson {
                        
                        if !showTitleObtained.isEmpty {
                            
                            showTitle = showTitleObtained
                            
                        } else {
                            showTitle = "No show title is available!"
                        }
                        
                    } else {
                        showTitle = "No show title is available!"
                    }
                    
                    //--------
                    // Show ID
                    //--------
                    
                    let idFromJson: String? = "\(showDictionary["id"] as! Int)"
                    
                    if let showIdObtained = idFromJson {
                        
                        if !showIdObtained.isEmpty {
                                showId = showIdObtained
                        } else {
                            showId = "-1"
                        }
                    } else {
                        showId = "-1"
                    }

                    
                    
                    
                    /*
                     =============================================
                     |  Obtain Other Data from OMDb: STEP 2 & 3  |
                     =============================================
                     */
                    
                    //let showDBIdFromJson = showDictionary["id"] as! Int
                    
                    /*let imdbShowID: String? = imdbId(showDatabaseID: showDBIdFromJson)
                     
                     if let imdbShowIDobtained = imdbShowID {
                     
                     if imdbShowIDobtained.isEmpty {
                     // Skip this show due to insufficient data
                     break
                     }
                     
                     let omdbShow = omdbShowDictionary(imdbDatabaseID: imdbShowIDobtained) as Dictionary<String, AnyObject>
                     
                     //------------
                     // MPAA Rating
                     //------------
                     
                     let mpaaRatingFromJson: String? = omdbshow["Rated"] as! String?
                     
                     if let mpaaRatingObtained = mpaaRatingFromJson {
                     
                     if !mpaaRatingObtained.isEmpty {
                     
                     mpaaRating = mpaaRatingObtained
                     
                     } else {
                     mpaaRating = "MPAA rating is unavailable!"
                     }
                     
                     } else {
                     mpaaRating = "MPAA rating is unavailable!"
                     }
                     
                     //------------
                     // IMDb Rating
                     //------------
                     
                     let imdbRatingFromJson: String? = omdbshow["imdbRating"] as! String?
                     
                     if let imdbRatingObtained = imdbRatingFromJson {
                     
                     if !imdbRatingObtained.isEmpty {
                     
                     imdbRating = imdbRatingObtained
                     
                     } else {
                     imdbRating = "IMDb rating is unavailable!"
                     }
                     
                     } else {
                     imdbRating = "IMDb rating is unavailable!"
                     }
                     
                     //-------------
                     // Show Actors
                     //-------------
                     
                     let actorsFromJson: String? = omdbShow["Actors"] as! String?
                     
                     if let actorsObtained = actorsFromJson {
                     
                     if !actorsObtained.isEmpty {
                     
                     actors = actorsObtained
                     
                     } else {
                     actors = "Actors are unavailable!"
                     }
                     
                     } else {
                     actors = "Actors are unavailable!"
                     }
                     */
                    
                    
                    
                    
                    //----------------------------------------------------------------------
                    // Create a new show dictionary with the following KEY : VALUE pairings
                    //----------------------------------------------------------------------
                    
                    let newShowDictionary = ["posterImageURL": posterImageURL,
                                             "showTitle": showTitle,
                                             "id": "\(showId)"]
                    /*,
                     "mpaaRating": mpaaRating,
                     "imdbRating": imdbRating,
                     "actors": actors] */
                    
                    // Add the new show dictionary to the array of show dictionaries
                    self.arrayOfShowDictionaries.append(newShowDictionary as AnyObject)
                    
                    /* } else {
                     // Skip this show due to insufficient data
                     break
                     }
                     
                     }*/
                }
                
            } catch let error as NSError {
                
                showErrorMessage(title: "Error in JSON Data Serialization!", message: "Problem Description: \(error.localizedDescription)")
                return
            }
            
        } else {
            showErrorMessage(title: "Error in retrieving JSON data!", message: "Problem Description: \(jsonError!.localizedDescription)")
        }
        
        // Skipping shows due to insufficient data makes this test required
        if arrayOfShowDictionaries.count == 0 {
            
            showNoResultsFound(rowNumber: 0)
            return
        }
        
        // Update the TableView once the search is completed
        resultsTableView.reloadData()

    }
    /*
     -----------------------------
     MARK: - Display Error Message
     -----------------------------
     */
    
    func showErrorMessage(title errorTitle: String, message errorMessage: String) {
        
        /*
         Create a UIAlertController object; dress it up with title, message, and preferred style;
         and store its object reference into local constant alertController
         */
        let alertController = UIAlertController(title: "\(errorTitle)",
            message: "\(errorMessage)",
            preferredStyle: UIAlertControllerStyle.alert)
        
        // Create a UIAlertAction object and add it to the alert controller
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }

    
    // Display that no results were found
    func showNoResultsFound(rowNumber: Int) {
        
        let firstWebResultsCellIndexPath = NSIndexPath(row: rowNumber, section: 2)
        
        let cell = (resultsTableView.cellForRow(at: firstWebResultsCellIndexPath as IndexPath)!) as! SearchResultTableViewCell
        
        if rowNumber == 0 {
            cell.titleLabel!.text = "No results found."
        } else {
            cell.titleLabel!.text = "No episodes found!"
        }
        
        cell.accessoryType = .none
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
            return arrayOfShowDictionaries.count > 0 ? arrayOfShowDictionaries.count : 1
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
            
            // Disable selection highlighting for the cells
            cell.selectionStyle = .none
            
            // Section 0, row 0 is reserved for the search filtering cell
            if rowNumber == 0 {
        
                let thisCell = cell as! SearchFilterTableViewCell
                
                // Set up the filter cell
                thisCell.tableView = tableView
                
                // Set up the button image
                thisCell.showCollapseButton!.setImage(UIImage(named: "downArrowBlack")!, for: UIControlState())
            }
        }
        else if sectionNumber == 1 {
            
            // Cell is a local results data cell
            cell = tableView.dequeueReusableCell(withIdentifier: "resultCell")!
            let thisCell = cell as! SearchResultTableViewCell
            
            // Only display data while searching
            if (searchResultsController.isActive) {
                
                let result = localSearchResults[indexPath.row]
                
                thisCell.titleLabel!.text = result
                cell.imageView?.image = UIImage(named: result)
            }
        }
        else {
            // Cell is a web results data cell
            cell = tableView.dequeueReusableCell(withIdentifier: "resultCell")!
            let thisCell = cell as! SearchResultTableViewCell
            
            // If the user hasn't started the web query, give them a hint
            if arrayOfShowDictionaries.count == 0 {
                
                if searchResultsController.isActive {
                    thisCell.titleLabel!.text = "Hit Enter on your keyboard to search the web"
                    
                } else {
                    thisCell.titleLabel!.text = ""
                }
                
                // Clear out the cell
                cell.imageView!.image = nil
                cell.accessoryType = .none
            } else {
                
                // Format the cell
                cell.textLabel!.text = ""
                cell.accessoryType = .disclosureIndicator
                cell.imageView!.image = nil
                
                
                // Data was found from the web query
                // Obtain the Dictionary containing the data about the show at rowNumber
                let showDataDict = arrayOfShowDictionaries[rowNumber] as! Dictionary<String, AnyObject>
                
                //----------------------
                // Set Show Poster Image
                //----------------------
                
                let posterUrl = showDataDict["posterImageURL"] as! String
                
                if posterUrl != "unavailable" {
                    
                    let url = URL(string: posterUrl)
                    
                    var imageData: Data?
                    
                    do {
                        imageData = try Data(contentsOf: url!, options: NSData.ReadingOptions.mappedIfSafe)
                        
                    } catch let error as NSError {
                        print("Error occurred: \(error.localizedDescription)")
                        imageData = nil
                    }
                    
                    if let showPosterImage = imageData {
                        
                        // Show poster image data is successfully retrieved
                        thisCell.posterImageView!.image = UIImage(data: showPosterImage)
                        
                    } else {
                        thisCell.posterImageView!.image = UIImage(named: "noPosterImage.png")
                    }
                    
                } else {
                    thisCell.posterImageView!.image = UIImage(named: "noPosterImage.png")
                }
                
                thisCell.posterImageView!.contentMode = .scaleToFill
                
                //---------------
                // Set Show Title
                //---------------
                
                let showTitle = showDataDict["showTitle"] as! String
                
                thisCell.titleLabel!.text = showTitle
            }
        }
        
        return cell
    }
    
    // TableViewCell tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section: Int = indexPath.section
        let row: Int = indexPath.row
        
        // Section 0 is reserved for the filter view cell
        if section == 0 {
            return
        }
        
        let selectedShowTitle = (tableView.cellForRow(at: indexPath) as! SearchResultTableViewCell).titleLabel!.text
        
        // If a local show was selected
        if section == 1 {
            var selectedPlaylist = localPlaylists[section]
            
            // Get the show data
            var selectedShowData = NSMutableDictionary()
            
            // Search for the selected show
            for i in 0..<localPlaylists.count {
                selectedShowData.setValue((applicationDelegate.dict_PlaylistName_MediaName[localPlaylists[i]] as! NSMutableDictionary)[selectedShowTitle!.replacingOccurrences(of: "\\", with: "")], forKey: selectedShowTitle!)
                
                // Break once the show data is found
                if selectedShowData[selectedShowTitle!] != nil {
                    selectedPlaylist = localPlaylists[i]
                    break
                }
            }
            
            // Prepare the data to pass
            // dataToPass[0] = playlistName
            // dataToPass[1] = showName
            // dataToPass[2] = selectedShowData
            dataToPass[0] = selectedPlaylist
            dataToPass[1] = selectedShowTitle!
            dataToPass[2] = selectedShowData[selectedShowTitle!]!
            
            // Close the search bar
            searchResultsController.isActive = false
            
            
            performSegue(withIdentifier: "showLocalEpisodes", sender: self)
        } else if section == 2 {
            
            // Don't look up the empty cell
            if selectedShowTitle == "Tap 'Search' to search the web" {
                
                return
            }
            
            // An online show was selected
            
            // Since a URL cannot have spaces, replace each space in the movie name to search with +.
            //let selectedShowTitle = (tableView.cellForRow(at: indexPath) as! SearchResultTableViewCell).titleLabel!.text?.replacingOccurrences(of: " ", with: "+", options: [], range: nil)
            
            // Obtain the Dictionary containing the data about the show at rowNumber
            let showDataDict = arrayOfShowDictionaries[row] as! Dictionary<String, AnyObject>
            let showId: String = showDataDict["id"]! as! String
            
            // Search The show DB API to search for the entered query
            // This URL returns the JSON data of the shows found for the search query showNameToSearch as in STEP 1
            let apiURL = "http://api.themoviedb.org/3/tv/" + showId + "?api_key=\(tmdbApiKey)&language=en-US"
            
            // Create a URL object from the API URL string
            let url = URL(string: apiURL)
            
            var jsonError: NSError?
            
            // TODO: if slow, try using a NSURL session if this yields poor performance.
            // To obtain the best performance:
            // (1) Download data in multiple threads including background downloads using multithreading and Grand Central Dispatch.
            // (2) Store each image on the device after first download to prevent downloading it repeatedly.
            
            // Download the JSON via HTTP in a single thread.
            let jsonData: Data?
            do {
                jsonData = try Data(contentsOf: url!, options: NSData.ReadingOptions.dataReadingMapped)
                
            } catch let error as NSError {
                jsonError = error
                jsonData = nil
            }
            
            if let jsonDataFromApiUrl = jsonData {
                
                // JSON data is successfully retrieved
                
                do {
                    let jsonDataDictionary = try JSONSerialization.jsonObject(with: jsonDataFromApiUrl, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    
                    // Typecast the returned NSDictionary as Dictionary<String, AnyObject>
                    let showDataDictionary = jsonDataDictionary as! Dictionary<String, AnyObject>
                    
                    // listOfSeasonsis an Array of Dictionaries, where each Dictionary contains data about a season
                    let listOfSeasonsFound = showDataDictionary["seasons"] as! Array<AnyObject>
                    
                    let numberOfSeasonsFromJsonData = listOfSeasonsFound.count
                    
                    // No results were found
                    if numberOfSeasonsFromJsonData < 1 {
                        
                        showNoResultsFound(rowNumber: row)
                        return
                    }
                    
                    // Pass the list of seasons to the downstream ViewController
                    dataToPass[0] = selectedShowTitle!
                    dataToPass[1] = showDataDict["posterImageURL"] as! String
                    dataToPass[2] = listOfSeasonsFound
                    dataToPass[3] = showId
                    
                    // Pass the list of filters to the downstream ViewController
                    filtersToPass[2] = chosenHoliday
                    
                    
                    
                    // Close the search bar
                    searchResultsController.isActive = false
                    
                    // Show the show's data
                    performSegue(withIdentifier: "showOnlineEpisodes", sender: self)
                    
                } catch let error as NSError {
                    
                    showErrorMessage(title: "Error in JSON Data Serialization!", message: "Problem Description: \(error.localizedDescription)")
                    return
                }
                
            } else {
                showErrorMessage(title: "Error in retrieving JSON data!", message: "Problem Description: \(jsonError!.localizedDescription)")
            }
        }
        
    }
    
    /*
     ------------------------------
     MARK: - User Tapped Background
     ------------------------------
     */
    @IBAction func userTappedBackground(sender: AnyObject) {
        
        view.endEditing(true)
    }
    
    // Calls this function when the tap is recognized.
    func dismissKeyboard() {
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    /*
     --------------------------------------------
     MARK: - UITextFieldDelegate Protocol methods
     --------------------------------------------
     */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    /*
     * This method is called when the user:
     * (1) selects another UI object after editing in a text field
     * (2) taps Return on the keyboard
     */
    func textFieldDidEndEditing(_ textField: UITextField) {
        
         let filterCell = resultsTableView.cellForRow(at: NSIndexPath(row: 0, section: 0) as IndexPath) as! SearchFilterTableViewCell
        
        // Store the text entered
        filtersToPass[0] = filterCell.episodeNameTextField.text!
        filtersToPass[1] = filterCell.actorsTextField.text!
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
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let strTitle = holidays[row]
        let attString = NSAttributedString(string: strTitle, attributes: [NSForegroundColorAttributeName : UIColor.red])
        return attString
    }
    
    /*
     --------------------------------------------
     MARK: - UIPickerViewDelegate Protocol Method
     --------------------------------------------
     */
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        
//        return holidays[row]
//    }
    
    // Record the chosen holiday
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        chosenHoliday = holidays[row]
    }
    
    /**
     * -------------------------
     * MARK: - Prepare for segue
     * -------------------------
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showLocalEpisodes" {
            
            // Pass the data to the downstream ViewController
            let episodesViewController: EpisodesViewController = segue.destination as! EpisodesViewController
            episodesViewController.dataPassed = dataToPass
        } else if segue.identifier == "showOnlineEpisodes" {
            
            // Pass the data to the downstream ViewController
            let onlineEpisodesViewController: OnlineEpisodesViewController = segue.destination as! OnlineEpisodesViewController
            onlineEpisodesViewController.dataPassed = dataToPass
            onlineEpisodesViewController.filtersPassed = filtersToPass
        }
    }

}
