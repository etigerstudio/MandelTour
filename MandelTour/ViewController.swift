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
    @IBOutlet weak var mandelScrollView: NSScrollView!
    @IBOutlet weak var progressContainer: NSView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var progressLabel: NSTextField!
    
    var busy = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initDelegate()
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
        
        mandelScrollView.isHidden = true
        
        progressContainer.isHidden = true
        progressLabel.alphaValue = 0.8
    }
    
    func initDelegate() {
        MPIBroker.shared.viewDelegate = self
    }
    
    @IBAction func hideWelcome(_ sender: Any) {
        NSAnimationContext.current.duration = 0.15
        welcomeContainer.animator().isHidden = true
        mandelScrollView.isHidden = false
        invokeAgent()
    }
    
    func invokeAgent() {
        busy = true
        showProgress(busy)
        let _ = MPIBroker.shared.spawnAgents(minX: -2, maxX: 1, minY: -1.5, maxY: 1.5)
    }
    
    func showProgress(_ busy: Bool) {
        if busy {
            progressContainer.isHidden = false
            progressIndicator.startAnimation(nil)
        } else {
            progressContainer.animator().isHidden = true
            progressIndicator.stopAnimation(nil)
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension ViewController: MandelViewDelegate {
    func fetchRenderResults(path: String) {
        print("Fetching render results...")
        guard let subviews = mandelScrollView
            .contentView.documentView?.subviews else {
            return
        }
        for (i, imageView) in subviews.enumerated() {
            if let imageView = imageView as? NSImageView {
                imageView.image = NSImage(contentsOfFile:
                    path.appending("/mandel\(i).png"))
            }
        }
        
        busy = false
        showProgress(busy)
    }
}

protocol MandelViewDelegate: class {
    func fetchRenderResults(path: String)
}
