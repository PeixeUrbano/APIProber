//
//  AppDelegate.swift
//  Prober
//
//  Created by Daniel Bonates on 07/03/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import Cocoa

typealias JSONDict = [String: Any]

extension Double {
    
    var ns: NSNumber {
        return NSNumber(value: self)
    }
    
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private var savedInput: String? {
        get {
            return UserDefaults.standard.object(forKey: "input") as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "input")
        }
    }
    
    let dataService = DataService()
    
    @IBOutlet weak var window: NSWindow! {
        didSet {
            window.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
            window.titleVisibility = .visible
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
            
            window.backgroundColor = NSColor(calibratedRed:0.18, green:0.18, blue:0.21, alpha:1.00)
        }
    }
    
    @IBOutlet weak var errorsLabel: NSTextField!
    @IBOutlet weak var succesLabel: NSTextField!
    @IBOutlet weak var attemptsLabel: NSTextField!
    @IBOutlet weak var urlField: NSTextField!
    @IBOutlet weak var fireButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    
    var totalAttempts: Float = 0

    var errors: Float = 0 {
        didSet {
            updateInfo()
        }
    }
    
    var success: Float = 0 {
        didSet {
            updateInfo()
        }
    }
    
    var shouldStop = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        urlField.backgroundColor = NSColor(calibratedRed:0.21, green:0.21, blue:0.24, alpha:1.00)
        urlField.focusRingType = .none
        urlField.wantsLayer = true
        urlField.layer?.cornerRadius = 4
        
        window.makeFirstResponder(nil)
        
        let onColor = NSColor(calibratedRed:0.98, green:0.49, blue:0.48, alpha:1.00)
        let offColor = NSColor(calibratedRed:0.68, green:0.42, blue:0.43, alpha:1.00)
        
        let fireAttrString = NSAttributedString(string: fireButton.title, attributes: [NSForegroundColorAttributeName: onColor])
        let fireAttrAlternateString = NSAttributedString(string: fireButton.title, attributes: [NSForegroundColorAttributeName: offColor])
        
        fireButton.attributedTitle = fireAttrString
        fireButton.attributedAlternateTitle = fireAttrAlternateString
        
        let stopAttrString = NSAttributedString(string: stopButton.title, attributes: [NSForegroundColorAttributeName: onColor])
        let stopAttrAlternateString = NSAttributedString(string: stopButton.title, attributes: [NSForegroundColorAttributeName: offColor])
        stopButton.attributedTitle = stopAttrString
        stopButton.attributedAlternateTitle = stopAttrAlternateString
        
        urlField.stringValue = savedInput ?? ""
    }
    
    private lazy var percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        
        return formatter
    }()
    
    func updateInfo() {
        errorsLabel.stringValue = "\(Int(errors))"
        attemptsLabel.stringValue = "\(Int(totalAttempts))"
        
        if let percentage = percentFormatter.string(from: Double(success/totalAttempts).ns) {
            succesLabel.stringValue = "\(Int(success)) (\(percentage))"
        } else {
            succesLabel.stringValue = "\(Int(success))"
        }
    }
    
    @IBAction func fire(_ sender: Any) {
        
        guard !urlField.stringValue.isEmpty else { return }
        
        totalAttempts = 0
        errors = 0
        success = 0
        errorsLabel.stringValue = ""
        succesLabel.stringValue = ""
        attemptsLabel.stringValue = ""
        shouldStop = false
        probe()
        fireButton.isEnabled = false
        stopButton.isEnabled = true
    }

    @IBAction func stop(_ sender: NSButton) {
        shouldStop = true
        dataService.stop()
        fireButton.isEnabled = true
        stopButton.isEnabled = false
    }
    
    func probe() {
        
        guard !shouldStop, let url = URL(string: urlField.stringValue) else { return }
        
        savedInput = urlField.stringValue
        totalAttempts += 1
        
        let listResource = Resource<JSONDict>(url: url, parse: { data in
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else { return nil }
            return json
        })
        dataService.load(resource: listResource, completion: { dict in
            DispatchQueue.main.async {
                
                guard let dict = dict, let code = dict["code"] as? Int, code == 200 else {
                    
                    self.errors += 1
                    self.probe()
                    return
                    
                }
                
                self.success += 1
                self.probe()
            }
        })
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

