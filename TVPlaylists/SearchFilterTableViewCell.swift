//
//  SearchFilterTableViewCell.swift
//  TVPlaylists
//
//  Created by Patrick Gatewood on 12/4/16.
//  Copyright © 2016 Patrick Gatewood. All rights reserved.
//

import UIKit

class SearchFilterTableViewCell: UITableViewCell {

    // References to objects created on the Storyboayd
    @IBOutlet var episodeNameTextField: UITextField!
    @IBOutlet var showCollapseButton: UIButton!
    @IBOutlet var actorsTextField: UITextField!
    @IBOutlet var holidayPickerView: UIPickerView!

    // Reference to parent table view
    var tableView = UITableView()
    
    // Boolean determining if this cell is selected
    var filtersSelected = true
    
    @IBAction func showCollapseButtonTapped(_ sender: UIButton) {
        
        // Display the arrow to show that the filter cell can be expanded or collpased
        if filtersSelected {
            showCollapseButton.setImage(UIImage(named: "upArrow"), for: UIControlState())
        } else {
            showCollapseButton.setImage(UIImage(named: "downArrowBlack"), for: UIControlState())
        }
        
        // Negate the state of the filtersSelected boolean to indicate that the state has changed
        filtersSelected = !filtersSelected
        
        // Update this cell's TableView in order to expand or collapse the cell
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
