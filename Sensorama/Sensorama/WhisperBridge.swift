// From:
// https://github.com/hyperoslo/Whisper/issues/28

// WhisperBridge.swift

import Foundation
import Whisper

@objc public class WhisperBridge: NSObject {

    static public func whisper(text: String,
                               textColor: UIColor,
                               backgroundColor: UIColor,
                               toNavigationController: UINavigationController,
                               silenceAfter: NSTimeInterval,
                               images: [UIImage]?) {
        let message = Message(title: text, textColor: textColor, backgroundColor: backgroundColor, images: images)

        Whisper(message, to: toNavigationController, action: .Present)

        if silenceAfter > 0.1 {
            Silent(toNavigationController, after: silenceAfter)
        }
    }
}