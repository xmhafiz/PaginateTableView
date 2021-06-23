//
//  ViewController.swift
//  GithubRepoListInfinite
//
//  Created by Hafiz on 22/06/2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        title = "Github Users"
    }
}
