//
//  SongsViewController.swift
//  songdownloader
//
//  Created by Антон Братчик on 14.04.2018.
//  Copyright © 2018 Антон Братчик. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class SongsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var dataSource = [Song]()
    fileprivate let downloadService = DownloadService()
    
    private var player: AVAudioPlayer?
    private var currentPlayingSongId: Int?
    
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier:
            "backgroundSessionConfiguration")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadService.downloadsSession = downloadsSession
        
        var storedSongs: [Song]?
        
        let decoder = JSONDecoder()
        if let songsData = UserDefaults.standard.data(forKey: "songs") {
            storedSongs = try? decoder.decode([Song].self, from: songsData)
        }
                
        activityIndicator.startAnimating()
        NetworkManager.shared.getSongsList(completion: { [weak self] (data) in
            guard let strongSelf = self else {
                return
            }
            
            if let songsData = try? JSONDecoder().decode(SongsData.self, from: data) {
                if let storedSongs = storedSongs {
                    songsData.songs.forEach({ (gettedSong) in
                        if storedSongs.contains(gettedSong) {
                            var song = storedSongs[storedSongs.index(of: gettedSong)!]
                            song.recognizeState()
                            
                            strongSelf.dataSource.append(song)
                        } else {
                            strongSelf.dataSource.append(gettedSong)
                        }
                    })
                } else {
                    songsData.songs.forEach({ strongSelf.dataSource.append($0) })
                }
            }
            
            strongSelf.saveDataSource()
            
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
                strongSelf.activityIndicator.stopAnimating()
            }
        }) {  [weak self] (error) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.show(error: error)
            if let storedSongs = storedSongs {
                for storedSong in storedSongs {
                    var song = storedSong
                    song.recognizeState()
                    
                    strongSelf.dataSource.append(song)
                }
                
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    strongSelf.tableView.isHidden = true
                }
            }
            
            DispatchQueue.main.async {
                strongSelf.activityIndicator.stopAnimating()
            }
        }
    }
    
    // MARK: Helpers
    fileprivate func switchStateAndReloadCell(at indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.dataSource[indexPath.row].changeState()
            strongSelf.reloadCell(at: indexPath)
        }
    }
    
    fileprivate func reloadCell(at indexPath: IndexPath) {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    fileprivate func show(error: String) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            
            strongSelf.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: persist and load data
    fileprivate func saveDataSource() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(dataSource) {
            UserDefaults.standard.set(encoded, forKey: "songs")
        }
    }
}

// MARK: TableViewDataSource methods
extension SongsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songTableViewCell", for: indexPath) as! SongTableViewCell
        let songItem = dataSource[indexPath.row]
        
        var progress: Float = 0
        
        if let url = songItem.audioURL, let download = downloadService.activeDownloads[url] {
            progress = download.progress
        }
        
        cell.configure(with: songItem, progress: progress)
        cell.delegate = self
        
        return cell
    }
}

// MARK: Cell delegate
extension SongsViewController: SongTableViewCellDelegate {
    func changeState(for cell: SongTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            switch (dataSource[indexPath.row].state) {
            case .none:
                switchStateAndReloadCell(at: indexPath)
                downloadService.startDownload(dataSource[indexPath.row]) { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        strongSelf.show(error: "Audio file can't be downloaded")
                        strongSelf.dataSource[indexPath.row].resetState()
                        strongSelf.reloadCell(at: indexPath)
                    }
                }
            case .downloading:
                break
            case .play:
                player?.pause()
                switchStateAndReloadCell(at: indexPath)
                currentPlayingSongId = nil
            case .pause:
                if let url = dataSource[indexPath.row].localURL {
                    do {
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                        try AVAudioSession.sharedInstance().setActive(true)
                        
                        player = try AVAudioPlayer(contentsOf: url)
                        
                        player?.play()
                        
                        switchStateAndReloadCell(at: indexPath)
                        
                        if let id = currentPlayingSongId {
                            switchStateAndReloadCell(at: IndexPath(row: id,
                                                                   section: 0))
                        }
                        
                        currentPlayingSongId = dataSource[indexPath.row].id
                    } catch {
                        show(error: "Audio file can't be played")
                        dataSource[indexPath.row].resetState()
                        reloadCell(at: indexPath)
                    }
                } else {
                    show(error: "Audio file is broken, try to download again")
                    dataSource[indexPath.row].resetState()
                    reloadCell(at: indexPath)
                }
            }
        }
    }
}

// MARK: URLSession Download Delegate
extension SongsViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard let sourceURL = downloadTask.originalRequest?.url else {
            show(error: "Download failed, try again later")
            return
        }
        
        let download = downloadService.activeDownloads[sourceURL]
        downloadService.activeDownloads[sourceURL] = nil
        
        var fileName = sourceURL.lastPathComponent
        
        if let suggestedFileName = (downloadTask.response! as! HTTPURLResponse).suggestedFilename {
            fileName = suggestedFileName
        }

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsPath.appendingPathComponent(fileName)

        let fileManager = FileManager.default
        
        try? fileManager.removeItem(at: destinationURL)
        
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            if let id = download?.song.id {
                dataSource[id].localURL   = destinationURL
                dataSource[id].downloaded = true

                // very important to save updated data
                saveDataSource()
                switchStateAndReloadCell(at: IndexPath(row: id, section: 0))
            }
        } catch {
            show(error: "Audio file can't be stored, try again later")
            
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                if let id = download?.song.id {
                    strongSelf.dataSource[id].resetState()
                    strongSelf.reloadCell(at: IndexPath(row: id, section: 0))
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard let url = downloadTask.originalRequest?.url,
            let download = downloadService.activeDownloads[url]  else {
                show(error: "Download failed, try again later")
                return
        }
        
        var downloadSize = download.song.fileSize
        if totalBytesExpectedToWrite > 0 {
            downloadSize = totalBytesExpectedToWrite
        }
        
        download.progress = Float(totalBytesWritten) / Float(downloadSize)

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            if let index = download.song.id, let cell = strongSelf.tableView.cellForRow(at: IndexPath(row: index,
                                                                       section: 0)) as? SongTableViewCell {
                cell.updateDisplay(progress: download.progress)
            }
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}
