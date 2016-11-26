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
                               silenceAfter: TimeInterval,
                               images: [UIImage]?) {
        let message = Message(title: text, textColor: textColor, backgroundColor: backgroundColor, images: images)

        // Show and hide a message after delay
        show(whisper: message, to: toNavigationController, action: WhisperAction.show)
    }
}
