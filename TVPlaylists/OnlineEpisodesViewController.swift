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
    
    // Create and intialize fields
    var playListName: String = ""
    var posterUrl = "unavailable"
    var showName: String = ""
    var showData: NSMutableDictionary = NSMutableDictionary()
    var seasonData: Array<AnyObject> = []
    var seasons = [String]()
    var showId: String = "-1"
    var filtered = true;
    
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
        
        
        // --------------------------
        let episodeNameFilter = ""
        let actorsFilter = ""
        let holidayFilter = "Christmas"
        
        // TODO pass filters and check them idk
        if filtered {
            
            // First check the holiday filter since it eliminates the most results
//            if holidayFilter != "None" {
//                
//                
//                
//                
//                // http://imdbapi.poromenos.org/js/?name=once+upon+a+time&year=2011
//            }
        }
        
        
        
        // ------------------------------
        
        // Initially display seasons only
        tableViewList = seasons
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
            
            // TODO this image looks like poop
            cell.accessoryView = UIImageView(image: UIImage(named: "downArrowBlack"))
            
        } else { // Object is an array containing show data
            
            cell = tableView.dequeueReusableCell(withIdentifier: "episodeCell")!
            let thisCell = cell as! EpisodeTableViewCell
            
            // Disable cell highlighting on selection
            cell.selectionStyle = .none
            
            // Set up the cell's data
            let episodeData = tableViewList[rowNumber] as! [String]
            
            thisCell.episodeTitleLabel.text = episodeData[0]    // title
            thisCell.episodeTextView.text = episodeData[1]      // description
            thisCell.episodeRatingLabel.text = episodeData[2]   // rating
            
            // Add an add button to the cell
            let addButton = UIButton(type: .contactAdd)
            addButton.isUserInteractionEnabled = true
            addButton.addTarget(self, action: #selector(OnlineEpisodesViewController.addButtonPressed(_:)), for: .touchUpInside)
            cell.accessoryView = addButton
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
                
                //getDataFromServer(keyName: nameOfSelectedRow)
                
                //let episodesInSeason: [[String]] = showData[nameOfSelectedRow] as! [[String]]
                
                let episodesInSeason = getDataFromServer(keyName: nameOfSelectedRow)

                
                // Insert the String array episode data into the tableViewList
                for i in 0..<episodesInSeason.count {
                    rowNumber += 1
                    tableViewList.insert(episodesInSeason[i], at: rowNumber)
                }
                
            } else if let _ = tableViewList[rowNumber + 1] as? String {
                
                // The row below the selected season is also a season, implying that the selected row is not expanded
                
                // Expand the row
                let episodesInSeason = getDataFromServer(keyName: nameOfSelectedRow)
                
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
    
    
    func saveEpisode(alert: UIAlertAction!) {
        
        // Get the episode data to add
        let buttonCellIndex = episodesTableView.indexPathForRow(at: addButtonPosition)
        let episodeData = tableViewList[buttonCellIndex!.row] as! [String]
        
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
            let seasonNumber = episodeData[3]
            newShowDictionary.setValue([episodeData], forKey: seasonNumber)
            
            // Save the show's image 
            let fileManager = FileManager.default
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentDirectoryPath = paths[0] as String
            let writePath = documentDirectoryPath + "/\(showName)"
            let imageToSave = UIImagePNGRepresentation(posterImageView.image!)
            fileManager.createFile(atPath: writePath, contents: imageToSave, attributes: nil)
        } else {
            
            // Show already exists: add the episode
        }
        
        
        
        

    }
    
    
    // ------------------------------------------------------------------------------
    //                                Get data from server
    // ------------------------------------------------------------------------------
    
    func getDataFromServer(keyName: String) -> [[String]] {
        
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
                
                let numberOfSeasonsFromJsonData = listOfEpisodesFound.count
                
                // Add data to the show's dictionary stored locally
                var showDataArray = showData[keyName] as? [[String]]
                
                // Store the episode data
                for i in 1..<numberOfSeasonsFromJsonData {
                    
                    let episodeData = listOfEpisodesFound[i] as! Dictionary<String, AnyObject>
                    let episodeName = episodeData["name"] as! String
                    let episodeDescription = episodeData["overview"] as! String
                    let episodeSeason = "\(episodeData["season_number"] as! Int)"
                    
                    // Store the values, or a default value if not found
                    let stringDescription = episodeDescription == "" ? "No description available" : episodeDescription
                    let intRating = episodeData["vote_average"] as! Int
                    let stringRating = intRating == 0 ? "not rated" : "\(intRating)"
                    
                    
                    // Array already found and exists
                    if showDataArray != nil {
                        showDataArray!.append([episodeName, stringDescription, stringRating, episodeSeason])
                    } else {
                        // Create the array
                        showData.setValue([[String]](), forKey: keyName)
                        showDataArray = showData[keyName] as? [[String]]
                        showDataArray!.append([episodeName, stringDescription, stringRating, episodeSeason])
                    }
                }
                
                return showDataArray!
                
                
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
