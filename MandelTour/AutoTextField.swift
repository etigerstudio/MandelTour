//
//  AutoTextField.swift
//  MandelTour
//
//  Created by ALuier Bondar on 30/05/2018.
//  Copyright © 2018 E-Tiger Studio. All rights reserved.
//

import Cocoa

class AutoTextField: NSTextField {
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            perform(#selector(selectText(_:)), with: self, afterDelay: 0)
        }
        return result
    }
    
    /*override func selectAll(_ sender: Any?) {
        if let sender = sender as? NSTextField {
            sender.focusRingType = .none
            selectAll(sender)
            sender.focusRingType = .default
        }
    }*/
    
}
