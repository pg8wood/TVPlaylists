//
//  searchResultTableViewCell.swift
//  TVPlaylists
//
//  Created by Patrick Gatewood on 12/5/16.
//  Copyright © 2016 Patrick Gatewood. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {

    // References to objects created at design time on the StoryBoard
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
