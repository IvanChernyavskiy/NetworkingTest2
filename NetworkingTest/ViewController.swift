//
//  ViewController.swift
//  NetworkingTest
//
//  Created by Иван Чернявский on 20.04.2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleLable: UILabel!
    var networkManager = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func downloadPostsDidTap() {
        networkManager.getAllPosts { (posts) in
            DispatchQueue.main.async {
                self.titleLable.text = "Posts has been downloaded"
                }
                }
    }
}
