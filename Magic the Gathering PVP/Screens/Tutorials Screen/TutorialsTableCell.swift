//
//  tutorialTableCell.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 3/10/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import UIKit

class tutorialTableCell: UITableViewCell {
    
    @IBOutlet weak var videoTitle: UILabel!
    
    func setTutorial(title: String){
        videoTitle.text = title
    }
}

