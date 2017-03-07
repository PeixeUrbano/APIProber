//
//  PUView.swift
//  Prober
//
//  Created by Guilherme Rambo on 07/03/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import Cocoa

@IBDesignable class PUView: NSView {

    @IBInspectable var backgroundColor: NSColor? {
        didSet {
            layer?.backgroundColor = backgroundColor?.cgColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        wantsLayer = true
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        wantsLayer = true
    }
    
}
