//
//  PlaybackCoordinator.swift
//  TUFlix
//
//  Created by Oliver Krakora on 27.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import AVKit

class PlaybackCoordinator {
    
    static func playModally(on vc: UIViewController, url: URL?) {
        guard let playbackURL = url else {
            let alert = UIAlertController(title: L10n.Episodes.PlayUnavailable.title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: L10n.Global.Ok.title, style: .cancel, handler: nil))
            vc.present(alert, animated: true, completion: nil)
            return
        }
        displayPlayerController(on: vc, url: playbackURL)
    }
    
    private static func displayPlayerController(on vc: UIViewController, url: URL) {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        vc.present(controller, animated: true, completion: nil)
    }
}
