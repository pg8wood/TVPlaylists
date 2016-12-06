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
        
        // Load the show's image
        posterImageView.image = UIImage(named: showName)
        
        // Format the cell
        episodesTableView.estimatedRowHeight = 150
        episodesTableView.rowHeight = UITableViewAutomaticDimension
        
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
            
            // Set up the cell's data
            let episodeData = tableViewList[rowNumber] as! [String]
            
            thisCell.episodeTitleLabel.text = episodeData[0]    // title
            thisCell.episodeTextView.text = episodeData[1]      // description
            thisCell.episodeRatingLabel.text = episodeData[2]   // rating
            
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
                let episodesInSeason: [[String]] = showData[nameOfSelectedRow] as! [[String]]
                
                // Insert the String array episode data into the tableViewList
                for i in 0..<episodesInSeason.count {
                    rowNumber += 1
                    tableViewList.insert(episodesInSeason[i], at: rowNumber)
                }
            } else if let _ = tableViewList[rowNumber + 1] as? String {
                
                // The row below the selected season is also a season, implying that the selected row is not expanded
                
                // Expand the row
                let episodesInSeason: [[String]] = showData[nameOfSelectedRow] as! [[String]]
                
                // Insert the String array episode data into the tableViewList
                for i in 0..<episodesInSeason.count {
                    rowNumber += 1
                    tableViewList.insert(episodesInSeason[i], at: rowNumber)
                }
                
            } else { // Shrink the row
                
                // As long as the next row is not a season number, delete the row from the table view list
                let nameOfNextRow: String? = tableViewList[rowNumber + 1] as? String
                
                while nameOfNextRow == nil {
                    
                    tableViewList.remove(at: rowNumber + 1)
                    
                    // Break if the end of the table view list is reached
                    if rowNumber + 1 == tableViewList.count {
                        break
                    }
                }
            }
        }
        
        // Reload the table view's rows since the table view list has changed
        tableView.reloadData()
    }

}
