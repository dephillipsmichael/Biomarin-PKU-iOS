//
//  EmojiChoiceTableStepViewController.swift
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

import Foundation
import BridgeApp

open class EmojiChoiceTableStepViewController: SurveyStepViewController {
    
    open var emojiImageType: EmojiImageType = .emoji
    
    open override func setupHeader(_ header: RSDStepNavigationView) {
        super.setupHeader(header)
        
        if let tableHeader = header as? RSDTableStepHeaderView {            
            // Remove detail label text, as it is replaced by learn more
            tableHeader.detailLabel?.text = nil
        }
    }
    
    override open func setupButton(_ button: UIButton?, for actionType: RSDUIActionType, isFooter: Bool) {

        if let detail = uiStep?.detail,
            actionType == .navigation(.learnMore) {
            
            // Switch detail to learn more button
            button?.setTitle(detail, for: .normal)
            button?.addTarget(self, action: #selector(showLearnMore), for: .touchUpInside)
            
        } else {
            super.setupButton(button, for: actionType, isFooter: isFooter)
        }
    }
    
    override open func registerReuseIdentifierIfNeeded(_ reuseIdentifier: String) {
        let reuseId = RSDFormUIHint(rawValue: reuseIdentifier)
        if reuseId == .list {
            // Register our custom emoji cell type
            tableView.register(EmojiChoiceTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
            return
        }
        super.registerReuseIdentifierIfNeeded(reuseIdentifier)
    }
    
    override open func configure(cell: UITableViewCell, in tableView: UITableView, at indexPath: IndexPath) {
        
        // Call before super so that setting table item will have correct image type
        if let emojiCell = cell as? EmojiChoiceTableViewCell {
            emojiCell.emojiImageType = self.emojiImageType
        }
        
        super.configure(cell: cell, in: tableView, at: indexPath)
    }
}

public enum EmojiImageType: String {
    case emoji = "Emoji"
    case sleepEmoji = "SleepEmoji"
}

public class EmojiChoiceTableViewCell: RSDSelectionTableViewCell {
    
    internal let kTitleLeadingMargin: CGFloat = 108.0
    
    internal let kImageLeadingMargin: CGFloat = 28.0
    internal let kImageTopMargin: CGFloat = 12.0
    internal let kImageBottomMargin: CGFloat = 20.0
    internal let kImageCenterMargin: CGFloat = -8.0
    internal let kImageSize: CGFloat = 50.0
    
    // The number of emoji image types
    let emojiCount = 5
    
    open var emojiImageType: EmojiImageType = .emoji
    
    @IBOutlet public var emojiImageView: UIImageView?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        // Setup the emoji image constraints to set the height of the cell
        emojiImageView = UIImageView()
        contentView.addSubview(emojiImageView!)
        emojiImageView?.contentMode = .scaleAspectFit
        emojiImageView?.rsd_alignToSuperview([.leading], padding: kImageLeadingMargin)
        emojiImageView?.rsd_alignToSuperview([.top], padding: kImageTopMargin)
        emojiImageView?.rsd_alignToSuperview([.bottom], padding: kImageBottomMargin)
        emojiImageView?.rsd_makeHeight(.equal, kImageSize)
        emojiImageView?.rsd_makeWidth(.equal, kImageSize)
        emojiImageView?.translatesAutoresizingMaskIntoConstraints = false
        
        // The title label must now be shifted to the right and down,
        // So loop through all its constraints and remove leading and top
        let constraintsToRemove = contentView.constraints.filter { (constraint) -> Bool in
            guard let label = constraint.firstItem as? UILabel, label == titleLabel else { return false }
            return constraint.firstAttribute == .leading || constraint.firstAttribute == .top
        }
        constraintsToRemove.forEach({ $0.isActive = false })
        
        // Reset the constraints to the values we want
        titleLabel?.rsd_alignToSuperview([.leading], padding: kTitleLeadingMargin)
        titleLabel?.rsd_alignCenterVertical(padding: kImageCenterMargin / 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public var tableItem: RSDTableItem! {
        didSet {
            guard let item = tableItem as? RSDChoiceTableItem else { return }
            titleLabel?.text = item.choice.text
            detailLabel?.text = item.choice.detail
            isSelected = item.selected
            
            // Here we set the emoji image based on the choice value
            // Currently the only values compatible are 1-5
            if let strAnswer = item.choice.answerValue as? String,
                let intAnswer = Int(strAnswer),
                intAnswer > 0, intAnswer <= emojiCount {
                emojiImageView?.image = UIImage(named: "\(emojiImageType.rawValue)\(intAnswer)")
            } else {
                emojiImageView?.image = nil
            }
        }
    }
}

