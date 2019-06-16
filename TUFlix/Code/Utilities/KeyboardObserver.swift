//
//  Keyboard.swift
//  TUFlix
//
//  Created by Oliver Krakora on 16.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import CoreGraphics
import ReactiveSwift
import Result

class KeyboardObserver {
    
    struct KeyboardNotification {
        let beginFrame: CGRect
        let endFrame: CGRect
        let animationDuration: TimeInterval
        let animationCurve: UIView.AnimationCurve
        let willShow: Bool
        
        var keyboardHeight: CGFloat {
            return endFrame.height
        }
    }
    
    static func observeKeyboardChanges() -> Signal<KeyboardNotification, NoError> {
        let showNotification = NotificationCenter.default.reactive
            .notifications(forName: UIApplication.keyboardWillShowNotification)
        
        let hideNotification = NotificationCenter.default.reactive
            .notifications(forName: UIApplication.keyboardWillHideNotification)

        return Signal.merge(showNotification, hideNotification).map { notification in
            let beginFrame = notification.userInfo![UIWindow.keyboardFrameBeginUserInfoKey] as! CGRect
            let endFrame = notification.userInfo![UIWindow.keyboardFrameEndUserInfoKey] as! CGRect
            let animationDuration = notification.userInfo![UIWindow.keyboardAnimationDurationUserInfoKey] as! TimeInterval
            let animationCurveRawValue = notification.userInfo![UIWindow.keyboardAnimationCurveUserInfoKey] as! Int
            let animationCurve = UIView.AnimationCurve(rawValue: animationCurveRawValue)!
            
            return KeyboardNotification(beginFrame: beginFrame,
                                        endFrame: endFrame,
                                        animationDuration: animationDuration,
                                        animationCurve: animationCurve,
                                        willShow: notification.name == UIWindow.keyboardWillShowNotification)
        }
    }
}
