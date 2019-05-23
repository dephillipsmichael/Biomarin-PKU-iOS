//
//  PKURoundedButton.swift
//  BiomarinPKU
//
//  Created by Michael L DePhillips on 5/23/19.
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
//

import Foundation
import BridgeApp

open class PKURoundedButton: RSDRoundedButton {
    override open func commonInit() {
        super.commonInit()
        updateFont()
    }
    
    override open func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        super.setDesignSystem(designSystem, with: background)
        updateFont()
    }
    
    private func updateFont() {
        if let design = designSystem {
            self.titleLabel?.font = design.fontRules.font(for: .heading3)
        }
    }
}
