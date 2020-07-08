//
//  CustomButtonNode.swift
//  Eggin
//
//  Created by Benjamin Simpson on 7/7/20.
//  Copyright © 2020 Benjamin Simpson. All rights reserved.
//

import Foundation
import SpriteKit

enum ButtonNodeState {
    case Active, Selected, Hidden
}

class CustomButtonNode: SKSpriteNode {
    var buttonEnabled = true
    var isButtonEnabled: Bool = true
    /* Setup a dummy action closure */
    var selectedHandler: () -> Void = { print("No button action set") }

    /* Button state management */
    var state: ButtonNodeState = .Active {
        didSet {
                switch state {
                case .Active:
                    /* Enable touch */
                    self.isUserInteractionEnabled = true

                    /* Visible */
                    self.alpha = 1
                    break
                case .Selected:
                    /* Semi transparent */
                    self.alpha = 0.7
                    break
                case .Hidden:
                    /* Disable touch */
                    self.isUserInteractionEnabled = false

                    /* Hide */
                    self.alpha = 0
                    break
            }
        }
    }

    /* Support for NSKeyedArchiver (loading objects from SK Scene Editor */
    required init?(coder aDecoder: NSCoder) {

        /* Call parent initializer e.g. SKSpriteNode */
        super.init(coder: aDecoder)

        /* Enable touch on button node */
        self.isUserInteractionEnabled = true
    }

    // MARK: - Touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isButtonEnabled{
          // change state
            state = .Selected
        }

    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isButtonEnabled {
          // run code assigned by other section
            selectedHandler()
            // change state back to active
            state = .Active
        }

    }

}
