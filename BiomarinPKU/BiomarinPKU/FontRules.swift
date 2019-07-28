//
//  FontRules.swift
//  BiomarinPKU
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import BridgeApp

open class FontRules: RSDFontRules {
    
    public let latoRegularName      = "Lato-Regular"
    public let latoBoldName         = "Lato-Bold"
    public let latoBlackName        = "Lato-Black"
    public let latoLightName        = "Lato-Light"
    public let latoItalicName       = "Lato-Italic"
    public let latoBoldItalicName   = "Lato-BoldItalic"
    public let latoLightItalicName  = "Lato-LightItalic"
    
    override open func font(for buttonType: RSDDesignSystem.ButtonType) -> RSDFont {
        switch buttonType {
        case .primary:
            return RSDFont(name: latoBoldName, size: 20)!
        case .secondary:
            return RSDFont(name: latoBoldName, size: 20)!
        }
    }
    
    /// Returns the font to use for a given text type.
    ///
    /// - parameter textType: The text type for the font.
    /// - returns: The font to use for this text.
    override open func font(for textType: RSDDesignSystem.TextType) -> RSDFont {
        switch textType {
        case .heading1:
            return RSDFont(name: latoBoldName, size: 24)!
        case .heading2:
            return RSDFont(name: latoBoldName, size: 18)!
        case .heading3:
            return RSDFont(name: latoBoldName, size: 16)!
        case .heading4:
            return RSDFont(name: latoRegularName, size: 14)!
        case .fieldHeader:
            return RSDFont(name: latoBoldName, size: 16)!
        case .body:
            return RSDFont(name: latoRegularName, size: 18)!
        case .bodyDetail:
            return RSDFont(name: latoRegularName, size: 16)!
        case .small:
            return RSDFont(name: latoRegularName, size: 14)!
        case .microHeader:
            return RSDFont(name: latoBoldName, size: 12)!
        case .counter:
            return RSDFont(name: latoLightName, size: 80)!
        }
    }
}
