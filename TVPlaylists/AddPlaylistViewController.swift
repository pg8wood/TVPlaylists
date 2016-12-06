//
//  AddPlaylistViewController.swift
//  TVPlaylists
//
//  Created by Patrick Gatewood on 12/6/16.
//  Copyright © 2016 Patrick Gatewood. All rights reserved.
//

import UIKit

class AddPlaylistViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var playlistNameTextField: UITextField!
    
    // Input validation for the text field 
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "addPlaylist-Save" {
            
            // Disallow saving a blank playlist
            return playlistNameTextField.text! != ""
        }
        
        return false
    }
}
