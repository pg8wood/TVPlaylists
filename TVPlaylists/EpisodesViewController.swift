 //
//  EpisodesViewController.swift
//  TVPlaylists
//
//  Created by Patrick Gatewood on 12/2/16.
//  Copyright © 2016 Patrick Gatewood. All rights reserved.
//

import UIKit

class EpisodesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var episodesTableView: UITableView!
    
    
    // Data passed by an upstream ViewController
    // Format: 
    // dataPassed[0] = playlistName
    // dataPassed[1] = showName
    // dataPassed[2] = selectedShowData: NSMutableDictionary
    var dataPassed = [Any]()
    
    // Create and intialize fields
    var playListName: String = ""
    var showName: String = ""
    var showData: NSMutableDictionary = NSMutableDictionary()
    var seasons = [String]()
    
    // Keeps track of which rows to display.
    var tableViewList = [Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the passed data
        playListName = dataPassed[0] as! String
        showName = dataPassed[1] as! String
        showData = dataPassed[2] as! NSMutableDictionary
        seasons = showData.allKeys as! [String]
        
        // Obtain the show's poster image
        var showPosterImage: UIImage!
        
        let imageInXcAssets = UIImage(named: showName)
        
        // Image found in xcassetsFolder
        if imageInXcAssets != nil {
            showPosterImage = imageInXcAssets
        } else {
            
            // Image is in the Documents directory
            showPosterImage = loadImageFromDocumentsDirectory(imageName: showName)
        }
        
        posterImageView.image = showPosterImage
        
        // Format the cell
        episodesTableView.estimatedRowHeight = 150
        episodesTableView.rowHeight = UITableViewAutomaticDimension
        seasons.sort { $0 < $1}
        
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
            cell.accessoryView = UIImageView(image: UIImage(named: "downArrowWhite"))
            
        } else { // Object is an array containing show data
        
            cell = tableView.dequeueReusableCell(withIdentifier: "episodeCell")!
            let thisCell = cell as! EpisodeTableViewCell
            
            // Show the delete button if this view was launched from an editing parent ViewController
            //cell.isEditing = viewOpenedInEditMode
            
            // Set up the cell's data
            let episodeData = tableViewList[rowNumber] as! [Any]
            
            // Get a list of the actors in the episode
            var actors: String = "\n\nGuest Stars: \n"
            
            if episodeData.count >= 5 {
                let actorsInEpisodeArray: [Any] = episodeData[4] as! [Any]
                
                for actorObject in actorsInEpisodeArray {
                    let actorName = (actorObject as! Dictionary<String, Any>)["name"] as! String
                    actors.append("\(actorName), ")
                }
                
                let descriptionText = (episodeData[1] as? String)! + actors.trimmingCharacters(in: CharacterSet.init(charactersIn: ", "))
                thisCell.episodeTextView.text = descriptionText    // description
            }
                
            else {
                thisCell.episodeTextView.text = episodeData[1] as? String // description
            }
            
            thisCell.episodeTitleLabel.text = episodeData[0] as? String  // title
            thisCell.episodeRatingLabel.text = episodeData[2] as? String   // rating
            
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
                
                // Expand the row
                let episodesInSeason: [[Any]] = showData[nameOfSelectedRow] as! [[Any]]
                
                // Insert the String array episode data into the tableViewList
                for i in 0..<episodesInSeason.count {
                    rowNumber += 1
                    tableViewList.insert(episodesInSeason[i], at: rowNumber)
                }
            } else if let _ = tableViewList[rowNumber + 1] as? String {
                
                // The row below the selected season is also a season, implying that the selected row is not expanded
                
                // Expand the row
                let episodesInSeason: [[Any]] = showData[nameOfSelectedRow] as! [[Any]]
                
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
}
