//
//  ViewController.swift
//  GithubRepoListInfinite
//
//  Created by Hafiz on 22/06/2021.
//

import UIKit

class ViewController: UIViewController {
    // 1
    enum TableSection: Int {
        case userList
        case loader
    }
    
    @IBOutlet weak var tableView: UITableView!
    // 2
    private let pageLimit = 25
    private var currentLastId: Int? = nil
    
    private var users = [User]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchData()
    }
    
    private func setupView() {
        title = "Github Users"
        tableView.rowHeight = 64
        tableView.dataSource = self
        // 3
        tableView.delegate = self
    }
    
    // 4
    private func fetchData(completed: ((Bool) -> Void)? = nil) {
        GithubAPIManager.shared.getUsers(perPage: pageLimit, sinceId: currentLastId) { [weak self] result in
            switch result {
            case .success(let users):
                self?.users.append(contentsOf: users)
                // 5
                // assign last id for next fetch
                self?.currentLastId = users.last?.id
                completed?(true)
            case .failure(let error):
                print(error.localizedDescription)
                // 6
                completed?(false)
            }
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    // 7
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 8
        guard let listSection = TableSection(rawValue: section) else { return 0 }
        switch listSection {
        case .userList:
            return users.count
        case .loader:
            return users.count >= pageLimit ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = TableSection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        // 9
        switch section {
        case .userList:
            let repo = users[indexPath.row]
            cell.textLabel?.text = repo.name
            cell.textLabel?.textColor = .label
            cell.detailTextLabel?.text = "\(indexPath.row + 1)"
        case .loader:
            cell.textLabel?.text = "Loading.."
            cell.textLabel?.textColor = .systemBlue
        }
        return cell
    }
    
    // 10
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let section = TableSection(rawValue: indexPath.section) else { return }
        guard !users.isEmpty else { return }
        
        if section == .loader {
            print("load new data..")
            fetchData { [weak self] success in
                if !success {
                    self?.hideBottomLoader()
                }
            }
        }
    }
    // 11
    private func hideBottomLoader() {
        DispatchQueue.main.async {
            let lastListIndexPath = IndexPath(row: self.users.count - 1, section: TableSection.userList.rawValue)
            self.tableView.scrollToRow(at: lastListIndexPath, at: .bottom, animated: true)
        }
    }
}
