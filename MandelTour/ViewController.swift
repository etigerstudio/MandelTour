//
//  ViewController.swift
//  MandelbrotSolver
//
//  Created by ALuier Bondar on 25/05/2018.
//  Copyright © 2018 E-Tiger Studio. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {


    @IBOutlet weak var realAxisLabel: NSTextField!
    @IBOutlet weak var imagAxisLabel: NSTextField!
    @IBOutlet weak var rMinField: NSTextField!
    @IBOutlet weak var rMaxField: NSTextField!
    @IBOutlet weak var iMinField: NSTextField!
    @IBOutlet weak var iMaxField: NSTextField!
    @IBOutlet weak var manbelContainer: NSView!
    @IBOutlet weak var welcomeContainer: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //view.wantsLayer = true
       initView()
    }

    func initView() {
        let labelAlpha: CGFloat = 0.75
        realAxisLabel.alphaValue = labelAlpha
        imagAxisLabel.alphaValue = labelAlpha
        
        let fieldAlpha: CGFloat = 0.9
        rMinField.alphaValue = fieldAlpha
        rMaxField.alphaValue = fieldAlpha
        iMinField.alphaValue = fieldAlpha
        iMaxField.alphaValue = fieldAlpha
        
        manbelContainer.wantsLayer = true;
        manbelContainer.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.15).cgColor
    }
    
    @IBAction func hideWelcome(_ sender: Any) {
        welcomeContainer.animator().isHidden = true
    }
    
//    func clearBackground(view: NSTextField) {
//        view.backgroundColor = nil
//        view.drawsBackground = true
//    }
    
    /*override func viewDidAppear() {
        self.view.window?.titleVisibility = .hidden;
        self.view.window?.titlebarAppearsTransparent = true;
        self.view.window?.styleMask.insert(.fullSizeContentView);
    }*/
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

