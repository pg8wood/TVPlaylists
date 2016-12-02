//
//  PlayListTableViewCell.swift
//  TVPlaylists
//
//  Created by Patrick Gatewood on 12/2/16.
//  Copyright © 2016 Patrick Gatewood. All rights reserved.
//

import UIKit

class PlayListTableViewCell: UITableViewCell {

    @IBOutlet var scrollMenu: UIScrollView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
