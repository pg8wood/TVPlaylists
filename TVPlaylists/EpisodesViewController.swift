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
    // dataPassed[0] = playlistName
    // dataPassed[1] = showName
    // dataPassed[2] = selectedShowData
    var dataPassed = [Any]()
    
    // Create and intialize fields
    var playListName: String = ""
    var showName: String = ""
    var showData = [Any]()
    //var episodeNames = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the passed data
        playListName = dataPassed[0] as! String
        showName = dataPassed[1] as! String
        showData = dataPassed[2] as! [[String]]
        //episodeNames = showData.allKeys as! [String]
        
        // Load the show's image
        posterImageView.image = UIImage(named: showName)
        
        // Format the cell
        episodesTableView.estimatedRowHeight = 150
        episodesTableView.rowHeight = UITableViewAutomaticDimension
    }

 
    /*
     --------------------------------------
     MARK: - Table View Data Source Methods
     --------------------------------------
     */
    
    // Our tableView will only have one section
    func numberOfSections(in tableView: UITableView) -> Int {
        return showData.count
    }
    
    // Format the headerView and its label
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
     
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = UIColor.white
        headerView.backgroundView!.backgroundColor = UIColor.clear
    }
    
    // Each section in the TableView will have 1 row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    //-----------------------------
    // Set Title for Section Header
    //-----------------------------
    
    // Set the table view section header to be the country name
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let episodeData = showData[section] as! [String]
        
        return episodeData[0]
    }
    
    // -------------------------------------
    // Prepare and return a table View  cell
    // -------------------------------------
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Identify the row and section number
        let sectionNumber = (indexPath as NSIndexPath).section
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodeCell") as! EpisodeTableViewCell
        let episodeData = showData[sectionNumber] as! [String]

//        // Format the cell's textView
//        get self sizing cell....
        
        // Set the cell's text and rating
        cell.episodeTextView.text! = episodeData[1]
        cell.episodeRatingLabel.text! = episodeData[2]
        
        
        
        
        
        return cell
    }
    
    /*
     ----------------------------------
     MARK: - Table View Delegate Method
     ----------------------------------
     */
    
    // This method is invoked when the user taps a table view row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}
