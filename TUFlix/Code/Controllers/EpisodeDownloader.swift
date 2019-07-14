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
    
    private static let userDefaultsKey = "running_downloads"
    
    static let shared = EpisodeDownloader()
    
    class Download: Codable, Hashable {
        
        private enum CodingKeys: String, CodingKey {
            case episode
            case taskIdentifier
            case _progress
            case _state
        }
        
        enum State: String, Codable {
            case inProgress
            case cancelled
            case error
            case completed
        }
        
        let episode: Episode
        fileprivate let taskIdentifier: Int
        fileprivate let _progress: MutableProperty<Double>
        fileprivate let _state: MutableProperty<State>
        fileprivate var downloadTask: URLSessionDownloadTask?
        
        lazy var progress: Property<Double> = {
            return Property(_progress)
        }()
        
        var formattedProgress: String? {
            return Formatters.percentFormatter.string(from: progress.value as NSNumber)
        }
        
        lazy var state: Property<State> = {
            return Property(_state)
        }()
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.episode = try container.decode(Episode.self, forKey: .episode)
            self.taskIdentifier = try container.decode(Int.self, forKey: .taskIdentifier)
            self._progress = try MutableProperty(container.decode(Double.self, forKey: ._progress))
            self._state = try MutableProperty(container.decode(State.self, forKey: ._state))
        }
        
        init(episode: Episode, taskIdentifier: Int, downloadTask: URLSessionDownloadTask?) {
            self.episode = episode
            self._progress = MutableProperty(0)
            self._state = MutableProperty(.inProgress)
            self.downloadTask = downloadTask
            self.taskIdentifier = taskIdentifier
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(episode, forKey: .episode)
            try container.encode(taskIdentifier, forKey: .taskIdentifier)
            try container.encode(_progress.value, forKey: ._progress)
            try container.encode(_state.value, forKey: ._state)
        }
        
        static func == (_ lhs: Download, _ rhs: Download) -> Bool {
            return lhs.episode == rhs.episode
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(episode.id)
        }
    }
    
    var backgroundCompletionHandler: (() -> Void)?
    
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "tuflix")
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        return session
    }()
    
    private var disposable: Disposable?
    
    private let _downloads = MutableProperty<[Download]>([])
    
    lazy var downloads: Property<[Download]> = {
        return Property(_downloads)
    }()
    
    override init() {
        super.init()
        session.getTasksWithCompletionHandler { [weak self] (_, _, downloadTasks) in
            let downloads: [Download] = UserDefaults.standard.decode(for: EpisodeDownloader.userDefaultsKey, decoder: Decoders.standardJSON) ?? []
            for download in downloads {
                download.downloadTask = downloadTasks.first(where: { $0.taskIdentifier == download.taskIdentifier })
            }
            self?._downloads.value = downloads.filter { $0.downloadTask != nil }
        }
        setupBindings()
    }
    
    deinit {
        disposable?.dispose()
    }
    
    // MARK: Bindings
    private func setupBindings() {
        disposable = _downloads.signal.observeValues { [weak self] _ in
            self?.persistDownloads()
        }
    }
    
    // MARK: Persistance
    private func persistDownloads() {
        UserDefaults.standard.encode(_downloads.value, key: EpisodeDownloader.userDefaultsKey, encoder: Encoders.standardJSON)
    }
}

// MARK: Starting and manipulating downloads
extension EpisodeDownloader {
    
    @discardableResult
    func download(episode: Episode, url: URL) -> Download {
        let downloadTask = session.downloadTask(with: url)
        let download = Download(episode: episode, taskIdentifier: downloadTask.taskIdentifier, downloadTask: downloadTask)
        _downloads.value.append(download)
        downloadTask.resume()
        return download
    }
    
    @discardableResult
    func cancelDownload(for episodeId: Episode.Id) -> Download? {
        guard let download = _downloads.value.getDownload(for: episodeId) else { return nil }
        
        download.downloadTask?.cancel()
        download._state.value = .cancelled
        _downloads.value.removeDownload(for: episodeId)
        return download
    }
    
    func download(for episodeId: Episode.Id) -> Download? {
        return _downloads.value.getDownload(for: episodeId)
    }
}

// MARK: URLSessionDownloadDelegate
extension EpisodeDownloader: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let download = _downloads.value.getDownload(for: task.taskIdentifier) else { return }
        
        DispatchQueue.main.async { [weak self] in
            if error != nil {
                download._state.value = .error
            }
            
            self?._downloads.value.removeDownload(for: download.episode.id)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let download = _downloads.value.getDownload(for: downloadTask.taskIdentifier) else { return }
        
        EpisodeManager.shared.handleFinishedDownload(download: download, currentLocation: location) { [weak self] error in
            DispatchQueue.main.async { [weak self] in
                if error != nil {
                    download._state.value = .error
                } else {
                    download._state.value = .completed
                    self?._downloads.value.removeDownload(for: download.episode.id)
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let download = _downloads.value.getDownload(for: downloadTask.taskIdentifier) else { return }
        
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            download._progress.value = progress
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        backgroundCompletionHandler?()
    }
}

// MARK: Helper extension
fileprivate extension Array where Element == EpisodeDownloader.Download {
    
    mutating func removeDownload(for episodeId: Episode.Id) {
        removeAll(where: { $0.episode.id == episodeId })
    }
    
    func getDownload(for taskIdentifier: Int) -> EpisodeDownloader.Download? {
        return first(where: { $0.taskIdentifier == taskIdentifier })
    }
    
    func getDownload(for episodeId: Episode.Id) -> EpisodeDownloader.Download? {
        return first(where: { $0.episode.id == episodeId })
    }
}
