//
//  SearchViewController.swift
//  MusicApp
//
//  Created by Maksim Grischenko on 07.10.2022.
//

import UIKit
import Alamofire
struct TrackModel {
    var trackName: String
    var artistName: String
}
class SearchViewController: UITableViewController {
    
    private var timer: Timer?
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var tracks = [Track]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupSearchBar()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 80
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let track = tracks[indexPath.row]
        content.text = "\(track.trackName ?? "")\n\(track.artistName)"
        cell.textLabel?.numberOfLines = 2
        content.image = UIImage(named: "Image")
        cell.contentConfiguration = content
        return cell
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print(searchText)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            let url = "https://itunes.apple.com/search"
            let parametrs = ["term": "\(searchText)",
                             "limit": "10"]
            AF.request(url, method: .get, parameters: parametrs, encoding: URLEncoding.default).response { dataResponse in
                if let error = dataResponse.error {
                    print("Error received requesting data:\(error.localizedDescription)")
                    return
                }
                guard let data = dataResponse.data else { return }
                
                let decoder = JSONDecoder()
                do {
                    let objects = try decoder.decode(SearchResponse.self, from: data)
                    print("objects", objects)
                    self.tracks = objects.results
                    self.tableView.reloadData()
                    
                    
                } catch let jsonError {
                    print("failed to decode JSON", jsonError)
                }
    //            let someString = String(data: data, encoding: .utf8)
    //            print(someString ?? "")
            }
        })
    }
}
