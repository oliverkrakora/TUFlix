//
//  EpisodeDownloader.swift
//  TUFlix
//
//  Created by Oliver Krakora on 09.07.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import ReactiveSwift
import TUFlixKit

class EpisodeDownloader: NSObject {
    
    class Download {
        
        enum State: Equatable {
            case progress(Double)
            case error(Error)
            
            var formattedProgress: String? {
                switch self {
                case .progress(let progress):
                    return Formatters.percentFormatter.string(from: progress as NSNumber)
                default:
                    return nil
                }
            }
            
            static func == (lhs: EpisodeDownloader.Download.State, rhs: EpisodeDownloader.Download.State) -> Bool {
                switch (lhs, rhs) {
                case (.progress(let progress), .progress(let progress1)):
                    return progress == progress1
                default:
                    return false
                }
            }
        }
        
        let episode: Episode
        let episodeURL: URL
        fileprivate let _state = MutableProperty<State>(.progress(0))
        fileprivate let downloadTask: URLSessionDownloadTask
        
        lazy var state: Property<State> = {
            return Property(_state)
        }()
        
        init(episode: Episode, episodeURL: URL, downloadTask: URLSessionDownloadTask) {
            self.episode = episode
            self.episodeURL = episodeURL
            self.downloadTask = downloadTask
        }
    }
    
    static let shared = EpisodeDownloader()
        
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "tuflix")
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        return session
    }()
    
    private let _runningDownloads = MutableProperty<[Download]>([])
    
    lazy var runningDownloads: Property<[Download]> = {
       return Property(_runningDownloads)
    }()
    
    func download(episode: Episode, url: URL) {
        let downloadTask = session.downloadTask(with: url)
        let download = Download(episode: episode, episodeURL: url, downloadTask: downloadTask)
        _runningDownloads.value.append(download)
        downloadTask.resume()
    }
    
    func cancelDownload(for episodeId: Episode.Id) {
        guard let download = _runningDownloads.value.first(where: { $0.episode.id == episodeId }) else { return }
        download.downloadTask.cancel()
        _runningDownloads.value.removeDownload(for: episodeId)
    }
    
    func hasDownload(for episodeId: Episode.Id) -> Bool {
        return _runningDownloads.value.getDownload(for: episodeId) != nil
    }
}

extension EpisodeDownloader: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloadTask = task as? URLSessionDownloadTask, let downloadURL = downloadTask.originalRequest?.url else { return }
        guard let download = _runningDownloads.value.getDownload(for: downloadURL) else { return }
        
        if let error = error {
            download._state.value = .error(error)
        } else {
            _runningDownloads.value.removeDownload(for: download.episode.id)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let download = _runningDownloads.value.first(where: { $0.episodeURL == downloadTask.originalRequest?.url }) else { return }
        
        EpisodeManager.shared.handleFinishedDownload(download: download, currentLocation: location) { [weak self] error in
            if let error = error {
                download._state.value = .error(error)
            } else {
                self?._runningDownloads.value.removeDownload(for: download.episode.id)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let downloadURL = downloadTask.originalRequest?.url else { return }
        guard let download = _runningDownloads.value.getDownload(for: downloadURL) else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        download._state.value = .progress(progress)
    }
}

fileprivate extension Array where Element == EpisodeDownloader.Download {
    
    mutating func removeDownload(for episodeId: Episode.Id) {
        removeAll(where: { $0.episode.id == episodeId })
    }
    
    func getDownload(for episodeId: Episode.Id) -> EpisodeDownloader.Download? {
        return first(where: { $0.episode.id == episodeId })
    }
    
    func getDownload(for url: URL) -> EpisodeDownloader.Download? {
        return first(where: { $0.episodeURL == url })
    }
}
