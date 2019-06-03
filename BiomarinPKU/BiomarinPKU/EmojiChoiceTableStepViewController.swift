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

open class EmojiChoiceTableStepViewController: RSDTableStepViewController {
    
    open override func setupHeader(_ header: RSDStepNavigationView) {
        super.setupHeader(header)
        
        // TODO: mdephillips 6/3/19 how do I set a custom global close image?
        
        if let tableHeader = header as? RSDTableStepHeaderView {
            tableHeader.progressView?.isHidden = true
            
            // TODO: mdephillips 6/3/19 why isn't the design system be applied automatically?
            let primary = AppDelegate.designSystem.colorRules.backgroundPrimary
            tableHeader.setDesignSystem(AppDelegate.designSystem, with: primary)
            tableHeader.textLabel?.font = AppDelegate.designSystem.fontRules.font(for: .heading1)
            
            // Remove detail label text, as it is replaced by learn more
            tableHeader.detailLabel?.text = nil
        }
    }
    
    override open func setupButton(_ button: UIButton?, for actionType: RSDUIActionType, isFooter: Bool) {

        if let detail = uiStep?.detail,
            actionType == .navigation(.learnMore) {
            
            // Switch detail to learn more button
            button?.setTitle(detail, for: .normal)
            button?.addTarget(self, action: #selector(learnMoreTapped), for: .touchUpInside)
            
        } else {
            super.setupButton(button, for: actionType, isFooter: isFooter)
        }
    }
    
    @objc func learnMoreTapped() {
        
        // A trick to get bridge surveys to have learn more screens that
        // are customizable on bridge is to make special step identifiers
        // that follow the format "learn_more_[step_id_with_learn_more_action]
        let learnMoreStepIdentifier = "learn_more_\(self.stepViewModel.step.identifier)"
        
        if let taskViewModel = self.stepViewModel.parentTaskPath as? RSDTaskViewModel,
            let infoScreen = (taskViewModel.task?.stepNavigator as? SBBSurvey)?.elements.first(where: { ($0 as? SBBSurveyElement)?.identifier == learnMoreStepIdentifier }) as? SBBSurveyInfoScreen {
            
            // TODO: mdephillips 6/3/19 how do I get a UI format like
            // the old instruction step format?  I dont see an RSDInstructionStepObject
            let infoStep = RSDUIStepObject(identifier: infoScreen.identifier, type: .instruction)
            infoStep.title = infoScreen.title
            infoStep.text = infoScreen.text
            
            // TODO: mdephillips 6/3/19 how to make cancel button be back button?
            infoStep.shouldHideActions = [.navigation(.goBackward), .navigation(.goForward), .navigation(.skip)]
            
            var navigator = RSDConditionalStepNavigatorObject(with: [infoStep])
            navigator.progressMarkers = []
            let task = RSDTaskObject(identifier: step.identifier, stepNavigator: navigator)
            let taskVc = RSDTaskViewController(task: task)
            taskVc.delegate = self
            self.present(taskVc, animated: true, completion: nil)
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
                emojiImageView?.image = UIImage(named: "Emoji\(intAnswer)")
            } else {
                emojiImageView?.image = nil
            }
        }
    }
}

