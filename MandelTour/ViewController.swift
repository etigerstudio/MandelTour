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
    @IBOutlet weak var rootMandelContainer: NSView!
    @IBOutlet weak var welcomeContainer: NSView!
    @IBOutlet weak var progressContainer: NSView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet var numberFormatter: NumberFormatter!
    @IBOutlet weak var firstMandelContainer: NSView!
    @IBOutlet weak var secondMandelContainer: NSView!
    
    var busy = false
    var entered = false
    var hiresRender = false
    var useFirstContainer = false
    
    var accumulatedMagnification: CGFloat = 0.0
    var lastDeltaAnchor = CGPoint.zero
    var mappingRect = CGRect.zero
    var mappingRectTranlated = CGRect.zero
    var parameterX: (ratio: Double, c: Double) = (0,0)
    var parameterY: (ratio: Double, c: Double) = (0,0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initDelegate()
        //initMandelRange()
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
        
        rootMandelContainer.wantsLayer = true;
        rootMandelContainer.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.15).cgColor
        
        firstMandelContainer.isHidden = true
        firstMandelContainer.wantsLayer = true
        //firstMandelContainer.layer?.backgroundColor = CGColor(red: 0, green: 7, blue: 100, alpha: 1)
        secondMandelContainer.isHidden = true
        secondMandelContainer.wantsLayer = true
        
        progressContainer.isHidden = true
        progressLabel.alphaValue = 0.8
    }
    
    func initDelegate() {
        MPIBroker.shared.viewDelegate = self
    }
    
//    func initMandelRange() {
//        updateMandelTextualRange()
//    }
    
    override func viewDidAppear() {
        view.window?.delegate = self
    }
    
    func getAspectRatio() -> Double {
        return Double(rootMandelContainer.frame.width) /
            Double(rootMandelContainer.frame.height)
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
        let size = getRenderSize()
        let range = Mandel.shared.calibratedRange(width: Double(size.width), height: Double(size.height))
        switch tag {
        case 0:
            if range.minR != value {
                dirty = true
                Mandel.shared.range.minR = value
            }
        case 1:
            if range.maxR != value {
                dirty = true
                Mandel.shared.range.maxR = value
            }
        case 2:
            if range.minI != value {
                dirty = true
                Mandel.shared.range.minI = value
            }
        case 3:
            if range.maxI != value {
                dirty = true
                Mandel.shared.range.maxI = value
            }
        default:
            break
        }
        return dirty
    }
    
    func renderMandel() {
        updateMandelTextualRange()
        guard entered && !busy else {
            return
        }
        invokeAgent()
    }
    
    @IBAction func hideWelcome(_ sender: Any) {
        NSAnimationContext.current.duration = 0.15
        welcomeContainer.animator().isHidden = true
        //firstMandelContainer.isHidden = false
        entered = true
        renderMandel()
    }
    
    func invokeAgent() {
        busy = true
        showProgress(busy)
        
        let size = getRenderSize()
        let range = Mandel.shared.calibratedRange(width: Double(size.width), height: Double(size.height))
        let _ = MPIBroker.shared.spawnAgents(range: range, resX: size.width, resY: size.height)
    }
    
    func getRenderSize() -> (width: Int, height: Int) {
        let width: Int
        let height: Int
        if hiresRender {
            height = Int(ceil(rootMandelContainer.frame.height))
            width = Int(ceil(rootMandelContainer.frame.width))
        } else {
            height = Int(ceil(rootMandelContainer.frame.height/2))
            width = Int(ceil(rootMandelContainer.frame.width/2))
        }
        return (width: width, height: height)
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
        let size = getRenderSize()
        let range = Mandel.shared.calibratedRange(width: Double(size.width), height: Double(size.height))
        rMinField.doubleValue = range.minR
        rMaxField.doubleValue = range.maxR
        iMinField.doubleValue = range.minI
        iMaxField.doubleValue = range.maxI
    }
    
    override func mouseUp(with event: NSEvent) {
        retireFirstResponder()
    }
    
    @IBAction func magnifyMandel(_ sender: NSMagnificationGestureRecognizer) {
        switch sender.state {
        case .began:
            magnifyBegan(sender: sender)
        case .changed:
            magnifyChange(sender: sender)
        case .ended, .cancelled:
            magnifyEnd(sender: sender)
        default:
            print("Magnify state falls default.")
            break
        }
//        switch sender.state {
//        case .began:
//            print("began")
//        case .changed:
//            print("changed")
//        case .ended:
//            print("ended")
//        case .possible:
//            print("possible")
//        case .cancelled:
//            print("cancelled")
//        case .failed:
//            print("failed")
//        default:
//            print("default")
//        }
//        print(sender.magnification)
    }
    
}

extension ViewController: MandelViewDelegate {
    func fetchRenderResults(path: String) {
        print("Fetching render results...")
        
        useFirstContainer = !useFirstContainer
        let container = getPrimaryContainer()
        let secondaryContainer = getSecondaryContainer()
        let subviews = container.subviews
        
        for (i, imageView) in subviews.enumerated() {
            if let imageView = imageView as? NSImageView {
                imageView.image = NSImage(contentsOfFile:
                    path.appending("/mandel\(i).png"))
            }
        }
        //container.isHidden = true
        resetTransformForContainer(container)
        
        NSAnimationContext.current.duration = 0.15
        container.animator().isHidden = false
        secondaryContainer.animator().isHidden = true
        
        busy = false
        showProgress(busy)
    }
    
    func getPrimaryContainer() -> NSView {
        return useFirstContainer ? firstMandelContainer : secondMandelContainer
    }
    
    func getSecondaryContainer() -> NSView {
        return useFirstContainer ? secondMandelContainer : firstMandelContainer
    }
}

extension ViewController {
    func magnifyBegan(sender: NSMagnificationGestureRecognizer) {
        accumulatedMagnification = 1.0
        lastDeltaAnchor = .zero
        mappingRect = .zero
        mappingRectTranlated = .zero
        
        let container = getPrimaryContainer();
        adjustAnchor(origin: sender.location(in: container), container: container)
        adjustToMagnification(getRefinedMagnification(sender.magnification), origin: sender.location(in: container), container: container)
    }
    
    func magnifyChange(sender: NSMagnificationGestureRecognizer) {
        let container = getPrimaryContainer();
        adjustToMagnification(getRefinedMagnification(sender.magnification), origin: sender.location(in: container), container: container)
    }
    
    func magnifyEnd(sender: NSMagnificationGestureRecognizer) {
        let container = getPrimaryContainer();
        adjustToMagnification(getRefinedMagnification(sender.magnification), origin: sender.location(in: container), container: container)
        commitRangeChange()
        renderMandel()
    }
    
    func adjustAnchor(origin: CGPoint, container: NSView) {
        let dx = (container.frame.width / 2 - origin.x)
        let dy = (container.frame.height / 2 - origin.y)
        let dxf = dx / container.frame.width
        let dyf = dy / container.frame.height
        
        if let layer = container.layer {
            lastDeltaAnchor = CGPoint(x: dxf, y: dyf)
            layer.anchorPoint = CGPoint(x: 0.5 - dxf, y: 0.5 + dyf)
            layer.setAffineTransform(layer.affineTransform().translatedBy(x: -dx, y: +dy))
            
//            mappingRect = buildMappingRect()
//            mappingRectTranlated = mappingRect.applying(CGAffineTransform(translationX: mappingRect.size.width * -dxf, y: mappingRect.size.height * -dyf))
        }
    }
    
    func buildMappingRect() -> CGRect {
        let size = getRenderSize()
        let range = Mandel.shared.calibratedRange(width: Double(size.width), height: Double(size.height))
        
        return CGRect(x: CGFloat(range.minR), y: CGFloat(range.minI), width: CGFloat(range.maxR - range.minR), height: CGFloat(range.maxI - range.minI))
    }
    
    func viewToZPlane(coord: Double, ratio: Double, c: Double) -> Double {
        return coord * ratio + c
    }
    
    func determineParameter(frame: CGRect) {
        let size = getRenderSize()
        let range = Mandel.shared.calibratedRange(width: Double(size.width), height: Double(size.height))
        let ratioX = (range.maxR - range.minR) / Double(frame.width)
        let cX = range.minR - (range.maxR - range.minR) / Double(frame.width) * Double(frame.minX)
        parameterX = (ratio: ratioX, c: cX)
        let ratioY = (range.maxI - range.minI) / Double(frame.height)
        let cY = range.minI - (range.maxI - range.minI) / Double(frame.height) * Double(frame.minY)
        parameterY = (ratio: ratioY, c: cY)
    }
    
    func adjustToMagnification(_ magnification: CGFloat, origin: CGPoint, container: NSView) {
        if let layer = container.layer {
            let transform = layer.affineTransform().scaledBy(x: magnification, y: magnification)
            layer.setAffineTransform(transform)
            
            //mappingRectTranlated.applying(CGAffineTransform(scaleX: magnification, y: magnification))
            
            accumulatedMagnification *= magnification
            /*for view in container.subviews {
                view.wantsLayer = true
                view.layer?.setAffineTransform((view.layer!.affineTransform().scaledBy(x: magnification, y: magnification)))
            }*/
        }
    }
    
    func resetTransformForContainer(_ container: NSView) {
        container.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        container.layer?.setAffineTransform(CGAffineTransform(translationX: container.frame.width / 2, y: container.frame.height / 2).scaledBy(x: 1, y: -1))
    }
    
    func getRefinedMagnification(_ magnification: CGFloat) -> CGFloat {
        return magnification / 8 + 1
    }
    
    func commitRangeChange() {
        let container = getPrimaryContainer()
        let size = getRenderSize()
        let oldRange = Mandel.shared.calibratedRange(width: Double(size.width), height: Double(size.height))

        let of = container.frame
        guard let nf = container.layer?.frame,
            let anchor = container.layer?.anchorPoint else {
            return
        }

        let oc = CGPoint(x: of.origin.x + anchor.x * of.width, y: of.origin.x + anchor.y * of.height)
        
        let scale = (oc.y - nf.origin.y) / oc.y
        
//        let minViewR = oc.x - (oc.x - nf.origin.x) / scale
//        let minViewI = oc.y - (oc.y - nf.origin.y) / scale
//        let maxViewR = oc.x + (nf.maxX - oc.x) / scale
//        let maxViewI = oc.y + (nf.maxY - oc.y) / scale
        
        determineParameter(frame: nf)
        
        let minR = viewToZPlane(coord: Double(of.minX), ratio: parameterX.ratio, c: parameterX.c)
        let minI = viewToZPlane(coord: Double(of.minY), ratio: parameterY.ratio, c: parameterY.c)
        let maxR = viewToZPlane(coord: Double(of.maxX), ratio: parameterX.ratio, c: parameterX.c)
        let maxI = viewToZPlane(coord: Double(of.maxY), ratio: parameterY.ratio, c: parameterY.c)
        
        Mandel.shared.range = MandelRange(minR: minR, maxR: maxR, minI: minI, maxI: maxI)
////
////
//        let minR = oldRange.minR / Double(co.x) * Double(cn.x)
//        let minI = oldRange.minI / Double(co.y) * Double(cn.y)
//        let maxR = oldRange.maxR / Double(of.width - co.x) * Double(nf.width - cn.x)
//        let maxI = oldRange.maxI / Double(of.height - co.y) * Double(nf.height - cn.y)
////
////        let minR = oldRange.minR / Double(of.origin.x) * Double(nf.origin.x)
////        let maxR = oldRange.maxR / Double(of.origin.x + of.size.width) * Double(nf.origin.x + nf.size.width)
////        let minI = oldRange.minI / Double(of.origin.y) * Double(nf.origin.y)
////        let maxI = oldRange.maxI / Double(of.origin.y + of.size.height) * Double(nf.origin.y + nf.size.height)
//
//        let container = getPrimaryContainer()
//        let size = getRenderSize()
//        let oldRange = Mandel.shared.calibratedRange(width: Double(size.width), height: Double(size.height))
//
//        let xL = oldRange.maxR - oldRange.minR
//        let yL = oldRange.maxI - oldRange.minI
//        let xLN = xL / Double(accumulatedMagnification)
//        let yLN = yL / Double(accumulatedMagnification)
//        let dx = xL * Double(lastDeltaAnchor.x)
//        let dy = yL * Double(lastDeltaAnchor.y)
//
//        print(accumulatedMagnification)
//
//        let newRange = MandelRange(minR: oldRange.minR / Double(accumulatedMagnification) ,
//                                   maxR: oldRange.maxR / Double(accumulatedMagnification) ,
//                                   minI: oldRange.minI / Double(accumulatedMagnification) ,
//                                   maxI: oldRange.maxI / Double(accumulatedMagnification) )
//
//        Mandel.shared.range = newRange
    }
}

extension ViewController: NSWindowDelegate {
    func windowDidEndLiveResize(_ notification: Notification) {
        renderMandel()
    }
}

protocol MandelViewDelegate: class {
    func fetchRenderResults(path: String)
}
