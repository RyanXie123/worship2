//
//  HomeViewController.swift
//  Worship
//
//  Created by 谢汝 on 2020/7/28.
//  Copyright © 2020 谢汝. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    private var songBookTitle: String?
    private var originalSonglist = [String]()
    private var indexedSonglist: Array<Array<String>> = Array<Array<String>>()
    private var sectionNumTitleList = [String]()
    private var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        readSongData()
        setSearchController()
        title = songBookTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")

    }
    
    private func setSearchController() {
        searchController = UISearchController(searchResultsController: UIViewController())
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    func stripFileExtension ( _ filename: String ) -> String {
        var components = filename.components(separatedBy: ".")
        guard components.count > 1 else { return filename }
        components.removeLast()
        return components.joined(separator: ".")
    }

    private func readSongData()  {
          guard let path = Bundle.main.path(forResource: "enquan", ofType: "json"),
          let fileData = NSData(contentsOfFile: path) else {
              return
          }
          do {
              let json = try JSONSerialization.jsonObject(with: fileData as Data, options: .mutableContainers) as? NSDictionary
              if let jsonDic = json {
                  songBookTitle = jsonDic["book_name"] as! String?
                  let songList = jsonDic["song_list"] as! [String]
                  originalSonglist = songList
                  processSonglist(prefixLength: 3)
              }
              
          }catch {
              print(error)
          }
          
          
      }
      
      private func processSonglist(prefixLength: Int) {
          sectionNumTitleList.removeAll()
          indexedSonglist.removeAll()
          
          sectionNumTitleList.append("1")
          var sectionSonglist = [String]()
          //遍历歌单 将歌单分为 50个一组
          for (index,songName) in originalSonglist.enumerated() {
              sectionSonglist.append(songName)
              let endIndex = songName.index(songName.startIndex, offsetBy: prefixLength)
              let startIndex = songName.startIndex
              let realSongIndexString = songName[startIndex ..< endIndex]
              let realSongIndex = Int(realSongIndexString)
              
              if realSongIndex! % 50 == 0 {
                  sectionNumTitleList.append(String(realSongIndex!))
              }
              let is_last_song = (index == originalSonglist.count - 1)
              //50个一个section
              if (realSongIndex! % 50 == 0 || is_last_song) {
                  if (is_last_song) {
                      sectionSonglist.append(songName)
                  }
                  indexedSonglist.append(sectionSonglist)
                  sectionSonglist = [String]()
              }
          }
          
          
      }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionNumTitleList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let songlist = indexedSonglist[section]
        return songlist.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let songList = indexedSonglist[indexPath.section]
        let songName = songList[indexPath.row]
        cell.textLabel?.text = stripFileExtension(songName)
        return cell
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionNumTitleList
    }


}
