//
//  tutorialViewController.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 3/10/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import UIKit
import AVKit
import Firebase

class tutorialViewController: UIViewController {
    
    @IBOutlet weak var viewVP: UIView!
    @IBOutlet weak var tutorialsTableView: UITableView!
    
    var ref: DatabaseReference!
    
    var descriptions: [String] = [] {
        didSet {
            tutorialsTableView.reloadData()
        }
    }
    var titles: [String] = []
    
    var videoPlayer: AVPlayerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        getTutorialInformation()
        
        tutorialsTableView.backgroundView = UIImageView(image: UIImage(named: "background"))
        tutorialsTableView.delegate = self
        tutorialsTableView.dataSource = self
    }
    
    func getTutorialInformation(){
        let infoRef = ref.child("tutorials")
        infoRef.observe(.childAdded, with: { (snapshot) in
            self.descriptions.append(snapshot.value as! String)
            self.titles.append(snapshot.key)
        })
    }
    
    func playVideo(name: String, type: String) {
        let path = Bundle.main.path(forResource: name, ofType: type)
        let url = URL(fileURLWithPath: path!)
        let video = AVPlayer(url: url)
        
        self.videoPlayer = AVPlayerViewController()
        self.videoPlayer!.view.frame = viewVP.bounds
        self.videoPlayer!.player = video
        
        self.viewVP.addSubview(self.videoPlayer!.view)
        video.play()
    }
}

extension tutorialViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return descriptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "vidoeCell") as! tutorialTableCell
        
        cell.setTutorial(title: descriptions[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playVideo(name: titles[indexPath.row], type: "mov")
    }
}

