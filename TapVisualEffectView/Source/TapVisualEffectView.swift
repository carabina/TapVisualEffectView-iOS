//
//  TapVisualEffectView.swift
//  TapVisualEffectView
//
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import class TapNibView.TapNibView
import func UIKit.UIAccessibility.UIAccessibilityIsReduceTransparencyEnabled
import class UIKit.UIColor.UIColor
import class UIKit.UIDevice.UIDevice
import class UIKit.UIView.UIView
import class UIKit.UIVisualEffectView.UIVisualEffectView

/// This class watches whether reduce transparency feature is enabled and instead of blur uses opacity with alpha.
public class TapVisualEffectView: TapNibView {

    //MARK: - Public -
    //MARK: Properties
    
    /// Blur style. Animatable.
    public var style: TapBlurEffectStyle = .light {
        
        didSet {
            
            self.visualEffectView.effect = self.style.blurEffect
            self.updateTransparency()
            self.updateMask()
        }
    }
    
    public override var mask: UIView? {
        
        get {
            
            return self.currentMask
        }
        set {
            
            self.applyMask(newValue)
        }
    }
    
    public override class var bundle: Bundle {
        
        return .visualEffectViewResourcesBundle
    }
    
    //MARK: Methods
    
    public override func setup() {

        self.addTransparencyObserver()

        self.updateTransparency()
        self.updateMask()
    }
    
    deinit {
        
        self.removeTransparencyObserver()
    }
    
    //MARK: - Private -
    //MARK: Properties
    
    private var contentView: UIView? {
        
        return self.subviews.first
    }
    
    @IBOutlet private weak var visualEffectView: UIVisualEffectView!
    
    private var currentMask: UIView?
    
    //MARK: Methods
    
    private func addTransparencyObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(reduceTransparencyStatusDidChange(_:)), name: .UIAccessibilityReduceTransparencyStatusDidChange, object: nil)
    }
    
    private func removeTransparencyObserver() {
        
        NotificationCenter.default.removeObserver(self, name: .UIAccessibilityReduceTransparencyStatusDidChange, object: nil)
    }
    
    @objc private func reduceTransparencyStatusDidChange(_ notification: NSNotification) {
        
        DispatchQueue.main.async {
            
            self.updateTransparency()
            self.updateMask()
        }
    }
    
    private func updateTransparency() {
        
        if UIAccessibilityIsReduceTransparencyEnabled() {
            
            self.visualEffectView.isHidden = true
            self.contentView?.layer.backgroundColor = self.style.tintColor.cgColor
        }
        else {
            
            self.visualEffectView.isHidden = false
            self.contentView?.layer.backgroundColor = UIColor.clear.cgColor
        }
    }
    
    private func applyMask(_ mask: UIView?) {
        
        self.currentMask = mask
        self.updateMask()
    }
    
    private func updateMask() {
        
        let viewToApplyMask = UIAccessibilityIsReduceTransparencyEnabled() ? self.contentView : self.visualEffectView
        let viewToRemoveMask = UIAccessibilityIsReduceTransparencyEnabled() ? self.visualEffectView : self.contentView
        
        if UIDevice.current.isRunningIOS9OrLower {
            
            viewToApplyMask?.layer.mask = self.currentMask?.layer
            viewToRemoveMask?.layer.mask = nil
        }
        else {
            
            viewToApplyMask?.mask = self.currentMask
            viewToRemoveMask?.mask = nil
        }
    }
}
