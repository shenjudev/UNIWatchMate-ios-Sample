//
//  UIButton+Badge.swift
//  OraimoHealth
//
//  Created by Eleven on 2023/6/9.
//  Copyright © 2023 Transsion-Oraimo. All rights reserved.
//

import Foundation
import UIKit

public extension UIButton {

    private struct AssociatedKeys {
        static var badgeKey = "UIButton_badgeKey"
        static var badgeBGColorKey = "UIButton_badgeBGColorKey"
        static var badgeTextColorKey = "UIButton_badgeTextColorKey"
        static var badgeFontKey = "UIButton_badgeFontKey"
        static var badgePaddingKey = "UIButton_badgePaddingKey"
        static var badgeMinSizeKey = "UIButton_badgeMinSizeKey"
        static var badgeOriginXKey = "UIButton_badgeOriginXKey"
        static var badgeOriginYKey = "UIButton_badgeOriginYKey"
        static var shouldHideBadgeAtZeroKey = "UIButton_shouldHideBadgeAtZeroKey"
        static var shouldAnimateBadgeKey = "UIButton_shouldAnimateBadgeKey"
        static var badgeValueKey = "UIButton_badgeValueKey"
 
    }
    //MARK: - getters/setters
    var badge: UILabel? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.badgeKey) as? UILabel
        }

        set {
            objc_setAssociatedObject(self, &AssociatedKeys.badgeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Badge value to be display
    var badgeValue: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.badgeValueKey) as? String
        }


        set {
            objc_setAssociatedObject(self, &AssociatedKeys.badgeValueKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            // When changing the badge value check if we need to remove the badge
//                if (!badgeValue || [badgeValue isEqualToString:@""] || ([badgeValue isEqualToString:@"0"] && self.shouldHideBadgeAtZero)) {
            if newValue == nil || newValue == "" || (newValue == "0" && self.shouldHideBadgeAtZero) {
                self.removeBadge()
                return
            }
            
            if self.badge == nil {
                self.badge = UILabel(frame: CGRect(x: self.badgeOriginX, y: self.badgeOriginY, width: 12, height: 12))
                self.badge?.textColor            = self.badgeTextColor
                self.badge?.backgroundColor      = self.badgeBGColor
                self.badge?.font                 = self.badgeFont
                self.badge?.textAlignment        = .center
//                self.badge = badgeLabel
                self.badgeInit()
                self.addSubview(self.badge!)
                self.updateBadgeValueAnimated(false)
            }
            else {
                self.updateBadgeValueAnimated(true)
            }
            
        }
    }
    
    
    private func badgeInit() {
        // Default design initialization
        self.badgeBGColor   = .red
        self.badgeTextColor = .white
        self.badgeFont      = .systemFont(ofSize: 12)
        self.badgePadding   = 4
        self.badgeMinSize   = 8
        self.badgeOriginX   = self.frame.size.width - (self.badge?.frame.size.width ?? 0 / 2)
        self.badgeOriginY   = 3
        self.shouldHideBadgeAtZero = true
        self.shouldAnimateBadge = true
        // Avoids badge to be clipped when animating its scale
        self.clipsToBounds = false;
    }

    
    
    /// Badge background color
    var badgeBGColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.badgeBGColorKey) as? UIColor
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.badgeBGColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            if self.badge != nil {
                self.refreshBadge()
            }
        }
    }
    
    /// Badge background color
    var badgeTextColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.badgeTextColorKey) as? UIColor
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.badgeTextColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if self.badge != nil {
                self.refreshBadge()
            }
        }
    }
    
    /// Badge font
    var badgeFont: UIFont? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.badgeFontKey) as? UIFont
            
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.badgeFontKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if self.badge != nil {
                self.refreshBadge()
            }
        }
    }
    /// Padding value for the badge
    var badgePadding: Double {
        get {
            let number = objc_getAssociatedObject(self, &AssociatedKeys.badgePaddingKey) as? Double
            return number ?? 0
        }
        
        set {

            objc_setAssociatedObject(self, &AssociatedKeys.badgePaddingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if self.badge != nil {
                self.updateBadgeFrame()
            }
        }
    }
    
    /// Minimum size badge to small
    var badgeMinSize: Double {
        get {
            let number = objc_getAssociatedObject(self, &AssociatedKeys.badgeMinSizeKey) as? Double
            return number ?? 0
        }
        
        set {

            objc_setAssociatedObject(self, &AssociatedKeys.badgeMinSizeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if self.badge != nil {
                self.updateBadgeFrame()
            }
        }
    }
    
    /// Values for offseting the badge over the BarButtonItem you picked
    var badgeOriginX: Double {
        get {
            let number = objc_getAssociatedObject(self, &AssociatedKeys.badgeOriginXKey) as? Double
            return number ?? 0
        }
        
        set {

            objc_setAssociatedObject(self, &AssociatedKeys.badgeOriginXKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if self.badge != nil {
                self.updateBadgeFrame()
            }
        }
    }
    
    var badgeOriginY: Double {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.badgeOriginYKey) as? Double ?? 0
        }
        
        set {

            objc_setAssociatedObject(self, &AssociatedKeys.badgeOriginYKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if self.badge != nil {
                self.updateBadgeFrame()
            }
        }
    }
    
    /// In case of numbers, remove the badge when reaching zero
    var shouldHideBadgeAtZero: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.shouldHideBadgeAtZeroKey) as? Bool ?? false
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.shouldHideBadgeAtZeroKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Badge has a bounce animation when value changes
    var shouldAnimateBadge: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.shouldAnimateBadgeKey) as? Bool ?? false
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.shouldAnimateBadgeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    //MARK: - Utility methods
    private func refreshBadge() {
        self.badge?.textColor        = self.badgeTextColor
        self.badge?.backgroundColor  = self.badgeBGColor
        self.badge?.font             = self.badgeFont
    }

    private func badgeExpectedSize() ->CGSize {
        // When the value changes the badge could need to get bigger
        // Calculate expected size to fit new value
        // Use an intermediate label to get expected size thanks to sizeToFit
        // We don't call sizeToFit on the true label to avoid bad display
        if let badgeLabel = self.badge {
            let frameLabel = self.duplicateLabel(labelToCopy: badgeLabel)
            frameLabel.sizeToFit()
            return frameLabel.frame.size

        }
        return CGSizeZero
    }
    
    private func duplicateLabel(labelToCopy: UILabel) ->UILabel {
        let duplicateLabel = UILabel(frame: labelToCopy.frame)
        duplicateLabel.text = labelToCopy.text
        duplicateLabel.font = labelToCopy.font
        
        return duplicateLabel;
    }
    
    private func updateBadgeFrame() {
        
        let expectedLabelSize = self.badgeExpectedSize()
        
        // Make sure that for small value, the badge will be big enough
        var minHeight = expectedLabelSize.height
        // Using a const we make sure the badge respect the minimum size
        minHeight = (minHeight < self.badgeMinSize) ? self.badgeMinSize : expectedLabelSize.height
        var minWidth = expectedLabelSize.width;
        let padding = self.badgePadding;
        
        // Using const we make sure the badge doesn't get too smal
        minWidth = (minWidth < minHeight) ? minHeight : expectedLabelSize.width;
        self.badge?.frame = CGRect(x: self.badgeOriginX, y: self.badgeOriginY, width: minWidth + padding, height: minHeight + padding)
        self.badge?.layer.cornerRadius = (minHeight + padding) / 2
        self.badge?.layer.masksToBounds = true

    }
    
    /// Handle the badge changing value
    private func updateBadgeValueAnimated(_ animated:Bool) {
        // Bounce animation on badge if value changed and if animation authorized
        if animated, self.shouldAnimateBadge, !(self.badge?.text == self.badgeValue) {
            let animation = CABasicAnimation(keyPath: "transform.scala")
            animation.fromValue = 1.5
            animation.toValue = 1
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.3, 1, 1)
            self.badge?.layer.add(animation, forKey: "bounceAnimation")
        }
        // Set the new value
        self.badge?.text = self.badgeValue
        
        // Animate the size modification if needed
        let duration = (animated && self.shouldAnimateBadge) ? 0.2 : 0
        UIView.animate(withDuration: duration) {
            self.updateBadgeFrame()
        }

    }
    
    private func removeBadge() {
        UIView.animate(withDuration: 0.2) {
            self.badge?.transform = CGAffineTransform(scaleX: 0, y: 0)
        } completion: { finished in
            self.badge?.removeFromSuperview()
            self.badge = nil
        }
    }
    
}

