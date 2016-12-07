//
//  EOnlinepisodesViewController.swift
//  TVPlaylists
//
//  Created by Patrick Gatewood on 12/2/16.
//  Copyright © 2016 Patrick Gatewood. All rights reserved.
//

import UIKit

class OnlineEpisodesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var episodesTableView: UITableView!
    
    // Data passed by an upstream ViewController
    // Format:
    // dataPassed[0] = showName
    // dataPassed[1] = posterURL
    // dataPassed[2] = dictionary of seasons
    // dataPassed[3] = showId
    var dataPassed = [Any]()
    var filtersPassed: [String] = ["", "", ""]
    var filtersWerePassed: Bool = false
    
    // Create and intialize fields
    var playListName: String = ""
    var posterUrl = "unavailable"
    var showName: String = ""
    var showData: NSMutableDictionary = NSMutableDictionary()
    var seasonData: Array<AnyObject> = []
    var allEpisodeData = [[[Any]]]()
    var seasons = [String]()
    var showId: String = "-1"
    
    // Loading icon and overlay
    var activityView: UIActivityIndicatorView? = nil
    var overlayView: UIView? = nil
    
    // The position of the add button that will be pressed
    var addButtonPosition: CGPoint = CGPoint.zero
    
    // My TMDB API Key
    let tmdbApiKey: String = "68060180bf3305a501c36e9a7ca5f03c"
    
    // Keeps track of which rows to display.
    var tableViewList = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the passed data
        showName = dataPassed[0] as! String
        posterUrl = dataPassed[1] as! String
        seasonData = dataPassed[2] as! Array<AnyObject>
        showId = dataPassed[3] as! String
        
        //----------------------
        // Set Show Poster Image
        //----------------------
        
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
                posterImageView.image = UIImage(data: showPosterImage)
                
            } else {
                posterImageView.image = UIImage(named: "noPosterImage.png")
            }
            
        } else {
            posterImageView.image = UIImage(named: "noPosterImage.png")
        }
        
        // Get the list of seasons
        for i in 0..<seasonData.count {
            
            let seasonDictionary = seasonData[i] as! Dictionary<String, AnyObject>
            seasons.append("\(seasonDictionary["season_number"] as! Int)")
        }
        
        // Format the cell
        episodesTableView.estimatedRowHeight = 150
        episodesTableView.rowHeight = UITableViewAutomaticDimension
        
        
        // -------------------------
        // Get the passed in filters
        // -------------------------
        let episodeNameFilter = filtersPassed[0]
        let actorsFilter = filtersPassed[1]
        let holidayFilter = filtersPassed[2]
        filtersWerePassed = (episodeNameFilter != "" || actorsFilter != "" || holidayFilter != "None")
        
        // Show that the view is curently loading
        createLoadingAnimation()
    }
    
    // After the view has appeared, start loading the data
    override func viewDidAppear(_ animated: Bool) {
        
        if filtersWerePassed {
            // Get the show's episodes from the server
            for i in 0..<seasonData.count {
                let episodeData = getDataFromServer(keyName: seasons[i])
                allEpisodeData.append(episodeData)
            }
            
            let episodeNameFilter = filtersPassed[0]
            let actorsFilter = filtersPassed[1]
            let holidayFilter = filtersPassed[2]
            
            
            // Only get episodes containing the selected name
            for i in (0 ..< allEpisodeData.count).reversed() {
                
                // Search each episode
                for j in (0 ..< allEpisodeData[i].count).reversed() {
                    
                    let episodeData = allEpisodeData[i][j]
                    let episodeName = episodeData[0] as! String
                    let episodeDescription = episodeData[1] as! String
                    let actorsInEpisode: [Any] = episodeData[4] as! [Any]
                    
                    // Filter episodes by name
                    if episodeNameFilter != "" && !(episodeName.lowercased().contains(episodeNameFilter.lowercased())) {
                        allEpisodeData[i].remove(at: j)
                    } else if actorsFilter != "" {
                        var foundActorInEpisode: Bool = false
                        
                        // Check the actors 
                        for i in 0..<actorsInEpisode.count {
                            let actorData = actorsInEpisode[i] as! Dictionary<String, Any>
                            let actorName = actorData["name"] as! String
                            
                            if actorName.contains(actorsFilter) {
                                foundActorInEpisode = true
                                break
                            }
                        }
                        
                        if !foundActorInEpisode {
                            allEpisodeData[i].remove(at: j)
                        }
                    }
                    else if holidayFilter != "None" && !(episodeDescription.lowercased().contains(holidayFilter.lowercased())) {
                        // Filter episodes by holiday episodes
                        allEpisodeData[i].remove(at: j)
                    }
                    
                    // Remove the season from the list of seasons if it is empty
                    if allEpisodeData[i].count == 0 {
                        allEpisodeData.remove(at: i)
                        break
                    }
                    
                }
            }
        }
        
        if filtersWerePassed {
            seasons.removeAll(keepingCapacity: false)
            
            for n in 0..<allEpisodeData.count {
                
                // Get the season number for the first episode in each season found
                let seasonNumberString = allEpisodeData[n][0][3] as! String
                
                if !seasons.contains(seasonNumberString){
                    seasons.append(seasonNumberString)
                }
            }
        }
        
        // Initially display seasons only
        tableViewList = seasons
        
        // Data retrieved; hide the loading animation
        hideLoadingAnimation()
        
        // If no results were found, tell the user.
        if tableViewList.count == 0 {
            showErrorMessage(title: "Search Failed", message: "No results were found. Please try searching with different filters.")
        }
        
        episodesTableView.reloadData()
    }
    
    
    /*
     --------------------------------------
     MARK: - Table View Data Source Methods
     --------------------------------------
     */
    
    // Our tableView will only have one section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Each section in the TableView will have 1 row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableViewList.count
    }
    
    // ------------------------------------
    // Prepare and return a table View cell
    // ------------------------------------
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Identify the row number
        let rowNumber = (indexPath as NSIndexPath).row
        
        var cell: UITableViewCell
     
        // If the object is a String, it is a season number.
        if let rowName = tableViewList[rowNumber] as? String {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "seasonCell")! as UITableViewCell
            
            // Set the label text of the cell to be the row name
            cell.textLabel!.text = "Season \(rowName)"
            cell.textLabel!.textColor = UIColor.white
            
            // Disable cell highlighting on selection
            cell.selectionStyle = .none
            
            // Display an arrow to indicate the cell has children
            cell.accessoryView = UIImageView(image: UIImage(named: "downArrowWhite"))
            
        } else { // Object is an array containing show data
            
            cell = tableView.dequeueReusableCell(withIdentifier: "episodeCell")!
            let thisCell = cell as! EpisodeTableViewCell
            
            // Disable cell highlighting on selection
            cell.selectionStyle = .none
            
            // Set up the cell's data
            let episodeData = tableViewList[rowNumber] as! [Any]
            
            if episodeData.count >= 2 {
                
                // Get a list of the actors in the episode
                var actors: String = "\n\nGuest Stars: \n"
                let actorsInEpisodeArray: [Any] = episodeData[4] as! [Any]
                
                for actorObject in actorsInEpisodeArray {
                    let actorName = (actorObject as! Dictionary<String, Any>)["name"] as! String
                    actors.append("\(actorName), ")
                }
    
                var descriptionText: String
                
                if actors != "\n\nGuest Stars: \n" {
                    descriptionText = (episodeData[1] as? String)! + actors.trimmingCharacters(in: CharacterSet.init(charactersIn: ", "))
                } else {
                    descriptionText = episodeData[1] as! String
                }
                
                thisCell.episodeTitleLabel.text = episodeData[0] as? String   // title
                thisCell.episodeTextView.text = descriptionText     // description
                thisCell.episodeRatingLabel.text = episodeData[2] as? String  // rating
                                  // guest stars
                
                
                
                // Add an add button to the cell
                let addButton = UIButton(type: .contactAdd)
                addButton.isUserInteractionEnabled = true
                addButton.addTarget(self, action: #selector(OnlineEpisodesViewController.addButtonPressed(_:)), for: .touchUpInside)
                cell.accessoryView = addButton
            } else {
                
                // No data was found
                thisCell.episodeTitleLabel.text = "No episode data found"   // title
                thisCell.episodeTextView.text = ""    // description
                thisCell.episodeRatingLabel.text = "Not rated"   // rating
                cell.accessoryView = .none
            }
        }
        
        
        return cell
    }
    
    
    // TableView cell tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Obtain the number of the selected row
        var rowNumber: Int = (indexPath as NSIndexPath).row
        
        // If a tableViewList[rowNumber] is a String, it is a season number
        if let nameOfSelectedRow: String = tableViewList[rowNumber] as? String {
            
            // If the selected row is the last row
            if rowNumber == tableViewList.count - 1 {
                
                // --------------
                // Expand the row
                // --------------
                
                var episodesInSeason: [[Any]]
        
                if filtersWerePassed {
                    episodesInSeason = allEpisodeData[rowNumber]
                } else {
                    
                    // Get data on-the-fly to save time
                    episodesInSeason = getDataFromServer(keyName: nameOfSelectedRow)
                }
                
                // Insert the String array episode data into the tableViewList
                for i in 0..<episodesInSeason.count {
                    rowNumber += 1
                    tableViewList.insert(episodesInSeason[i], at: rowNumber)
                }
                
            } else if let _ = tableViewList[rowNumber + 1] as? String {
                
                // The row below the selected season is also a season, implying that the selected row is not expanded
                
                // Expand the row
                var episodesInSeason: [[Any]]
                
                if filtersWerePassed {
                    episodesInSeason = allEpisodeData[rowNumber]
                } else {
                    
                    // Get data on-the-fly to save time
                    episodesInSeason = getDataFromServer(keyName: nameOfSelectedRow)
                }
                
                // Insert the String array episode data into the tableViewList
                for i in 0..<episodesInSeason.count {
                    rowNumber += 1
                    tableViewList.insert(episodesInSeason[i], at: rowNumber)
                }
                
            } else { // Shrink the row
                
                // As long as the next row is not a season number, delete the row from the table view list
                var nameOfNextRow: String? = tableViewList[rowNumber + 1] as? String
                
                while nameOfNextRow == nil {
                    
                    tableViewList.remove(at: rowNumber + 1)
                    
                    // Break if the end of the table view list is reached
                    if rowNumber + 1 == tableViewList.count {
                        break
                    }
                    
                    nameOfNextRow = tableViewList[rowNumber + 1] as? String
                    
                }
            }
        }
        
        // Reload the table view's rows since the table view list has changed
        tableView.reloadData()
    }
    
    /**
     * -------------------------------
     * MARK: - Cell Add Button Pressed
     * -------------------------------
     */
    func addButtonPressed(_ sender: UIButton) {
        // Episode data was tapped: add the episode to a playlist
        
        // Get the location of the button
        addButtonPosition = sender.convert(CGPoint.zero, to: episodesTableView)
        
        // Get the list of playlists
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let playlists: [String] = appDelegate.dict_PlaylistName_MediaName.allKeys as! [String]
        
        // Create an alert controller
        let alertController = UIAlertController(title: "Add to Playlist", message: "Choose a playlist to add this episode to.", preferredStyle: UIAlertControllerStyle.alert)
        
        for playlistName in playlists {
            alertController.addAction(UIAlertAction(title: playlistName, style: UIAlertActionStyle.default, handler: saveEpisode))
        }
        
        
        // Present the alert controller by calling the present method
        present(alertController, animated: true, completion: nil)
    }
    
    // Save the episode to the dictionary. 
    func saveEpisode(alert: UIAlertAction!) {
        
        // Get the episode data to add
        let buttonCellIndex = episodesTableView.indexPathForRow(at: addButtonPosition)
        var episodeData = tableViewList[buttonCellIndex!.row] as! [Any]
        
        // Get the name of the playlist
        let playlistName = alert.title!
        
        // Get the list of playlists
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Get the list of shows in the playlist
        let playlistDictionary: NSMutableDictionary = appDelegate.dict_PlaylistName_MediaName.value(forKey: playlistName) as! NSMutableDictionary
        
        // Show not found in playlist: add it to the dictionary
        
        if playlistDictionary[showName] == nil {
            
            playlistDictionary.setValue(NSMutableDictionary(), forKey: showName)
            let newShowDictionary: NSMutableDictionary = playlistDictionary.value(forKey: showName) as! NSMutableDictionary
            
            // Add the episode data to the dictionary.
            let seasonNumber = episodeData[3] as! String
            newShowDictionary.setValue([episodeData], forKey: seasonNumber)
            
            // Save the show's image
            let fileManager = FileManager.default
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentDirectoryPath = paths[0] as String
            let writePath = documentDirectoryPath + "/\(showName)"
            let imageToSave = UIImagePNGRepresentation(posterImageView.image!)
            fileManager.createFile(atPath: writePath, contents: imageToSave, attributes: nil)
            
            showErrorMessage(title: "Add Successful!", message: "Successfully added the episode to the chosen playlist.")
        } else {
            
            // Show already exists: add the episode
            let seasonNumber = episodeData[3]
            let seasonData = playlistDictionary[showName] as! NSMutableDictionary
            
            // Episodes already exist in the season: append the new episode
            if let episodesInSeason = seasonData[seasonNumber] as? [[Any]] {
                
                var episodes = episodesInSeason
                var shouldAdd: Bool = true
            
                // Check if episodes already contains the chosen episode
                for i in 0 ..< episodes.count {
                    
                    let episodeName = episodes[i][0] as! String
                    let newEpisodeName = episodeData[0] as! String
                    
                    if episodeName == newEpisodeName {
                        shouldAdd = false
                        break
                    }
                }
                
                // Only add the episode if it is not already present
                if shouldAdd {
                    episodes.append(episodeData)
                    seasonData[seasonNumber] = episodes
                    
                    showErrorMessage(title: "Add Successful!", message: "Successfully added the episode to the chosen playlist.")
                    
                } else {
                        showErrorMessage(title: "Add Failed", message: "The chosen episode is already present in the selected playlist.")
                }
          
            } else {
                
                // No episodes are in the season
                seasonData.setValue([episodeData], forKey: seasonNumber as! String)
                
                showErrorMessage(title: "Add Successful!", message: "Successfully added the episode to the chosen playlist.")
            }
        }
        
    }
    
    
    // ------------------------------------------------------------------------------
    //                                Get data from server
    // ------------------------------------------------------------------------------
    
    func getDataFromServer(keyName: String) -> [[Any]] {
        
        let apiURL = "http://api.themoviedb.org/3/tv/\(showId)/season/\(keyName)?api_key=\(tmdbApiKey)&language=en-US"
        
        // Create a URL object from the API URL string
        let url = URL(string: apiURL)
        
        var jsonError: NSError?
        
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
                let seasonDataDictionary = jsonDataDictionary as! Dictionary<String, AnyObject>
                
                // listOfEpisodes sis an Array of Dictionaries, where each Dictionary contains data about a season
                let listOfEpisodesFound = seasonDataDictionary["episodes"] as! Array<AnyObject>
                
                let numberOfEpisodesFromJsonData = listOfEpisodesFound.count
                
                // Add data to the show's dictionary stored locally
                var showDataArray = showData[keyName] as? [[Any]]
                
                if numberOfEpisodesFromJsonData > 0 {
                    // Store the episode data
                    for i in 0..<numberOfEpisodesFromJsonData {
                        
                        let episodeData = listOfEpisodesFound[i] as! Dictionary<String, AnyObject>
                        let episodeName = episodeData["name"] as! String
                        let episodeDescription = episodeData["overview"] as! String
                        let episodeSeason = "\(episodeData["season_number"] as! Int)"
                        let actorsInEpisode = episodeData["guest_stars"] as! [AnyObject]
                        
                        // Store the values, or a default value if not found
                        let stringDescription = episodeDescription == "" ? "No description available" : episodeDescription
                        let intRating = episodeData["vote_average"] as! Int
                        let stringRating = intRating == 0 ? "not rated" : "\(intRating)"
                        
                        
                        // Array already found and exists
                        if showDataArray != nil {
                            showDataArray!.append([episodeName, stringDescription, stringRating, episodeSeason, actorsInEpisode])
                        } else {
                            // Create the array
                            showData.setValue([[String]](), forKey: keyName)
                            showDataArray = showData[keyName] as? [[Any]]
                            showDataArray!.append([episodeName, stringDescription, stringRating, episodeSeason, actorsInEpisode])
                        }
                    }
                    
                    return showDataArray!
                }
                
                return [[]]
                
            } catch let error as NSError {
                
                showErrorMessage(title: "Error in JSON Data Serialization!", message: "Problem Description: \(error.localizedDescription)")
                return [[]]
            }
            
        } else {
            showErrorMessage(title: "Error in retrieving JSON data!", message: "Problem Description: \(jsonError!.localizedDescription)")
            return [[]]
        }
        
        // ----------------------------------------------------------------------------------
        //                                End get data from server
        // ----------------------------------------------------------------------------------
    }
    
    // -----------------------
    // Show loading animation
    // ----------------------
    func createLoadingAnimation() {
        
        // Set up the activityView
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView!.center = self.view.center
        activityView!.startAnimating()
        
        // Set up screen dimmer
        overlayView = UIView.init(frame: UIScreen.main.bounds)
        overlayView!.layer.backgroundColor = UIColor.init(white: 0.0, alpha: 0.5).cgColor
        
        // Add both views
        self.view.addSubview(overlayView!)
        self.view.addSubview(activityView!)
    }
    
    // ----------------------
    // Hide loading animation
    // ---------------------
    func hideLoadingAnimation() {
        
        activityView?.removeFromSuperview()
        overlayView?.removeFromSuperview()
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
    
    
}
