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
    @IBOutlet var numberFormatter: NumberFormatter!
    
    var busy = false
    var entered = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initDelegate()
        initMandelRange()
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
        
        //numberFormatter.positivePrefix = numberFormatter.plusSign
        
        manbelContainer.wantsLayer = true;
        manbelContainer.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.15).cgColor
        
        mandelScrollView.isHidden = true
        
        progressContainer.isHidden = true
        progressLabel.alphaValue = 0.8
    }
    
    func initDelegate() {
        MPIBroker.shared.viewDelegate = self
    }
    
    func initMandelRange() {
        updateMandelTextualRange()
    }
    
    func getAspectRatio() -> Double {
        return Double(mandelScrollView.frame.width) /
            Double(mandelScrollView.frame.height)
    }
    
    func retireFirstResponder() {
        view.window?.makeFirstResponder(view)
    }
    
    @IBAction func editDidEnd(_ sender: NSTextField) {
        let dirty = adjustMandelArg(tag: sender.tag, value: sender.doubleValue)
        retireFirstResponder()
        if dirty {
            renderMandel()
        }
    }
    
    func adjustMandelArg(tag: Int, value: Double) -> Bool {
        var dirty = false
        switch tag {
        case 0:
            if Mandel.shared.range.minR != value {
                dirty = true
                Mandel.shared.range.minR = value
            }
        case 1:
            if Mandel.shared.range.maxR != value {
                dirty = true
                Mandel.shared.range.maxR = value
            }
        case 2:
            if Mandel.shared.range.minI != value {
                dirty = true
                Mandel.shared.range.minI = value
            }
        case 3:
            if Mandel.shared.range.maxI != value {
                dirty = true
                Mandel.shared.range.maxI = value
            }
        default:
            break
        }
        updateMandelTextualRange()
        return dirty
    }
    
    func renderMandel() {
        guard entered && !busy else {
            return
        }
        invokeAgent()
    }
    
    @IBAction func hideWelcome(_ sender: Any) {
        NSAnimationContext.current.duration = 0.15
        welcomeContainer.animator().isHidden = true
        mandelScrollView.isHidden = false
        entered = true
        renderMandel()
    }
    
    func invokeAgent() {
        busy = true
        showProgress(busy)
        let range = Mandel.shared.calibratedRange(
            width: Double(mandelScrollView.frame.width),
            height: Double(mandelScrollView.frame.height))
        let _ = MPIBroker.shared.spawnAgents(range: range)
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
    
    func updateMandelTextualRange() {
        rMinField.doubleValue = Mandel.shared.range.minR
        rMaxField.doubleValue = Mandel.shared.range.maxR
        iMinField.doubleValue = Mandel.shared.range.minI
        iMaxField.doubleValue = Mandel.shared.range.maxI
    }
    
    override func mouseUp(with event: NSEvent) {
        retireFirstResponder()
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
        mandelScrollView.isHidden = true
        NSAnimationContext.current.duration = 0.15
        mandelScrollView.animator().isHidden = false
        
        busy = false
        showProgress(busy)
    }
}

protocol MandelViewDelegate: class {
    func fetchRenderResults(path: String)
}
