//
//  EFHSBView.swift
//  EFColorPicker
//
//  Created by EyreFree on 2017/9/29.
//
//  Copyright (c) 2017 EyreFree <eyrefree@eyrefree.org>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

// The view to edit HSB color components.
public class EFHSBView: UIView, EFColorView {

    private var colorWheel: EFColorWheelView!
    private var colorComponents: HSB = HSB(1, 1, 1, 1)

    weak public var delegate: EFColorViewDelegate?

    public var color: UIColor {
        get {
            return UIColor(
                hue: colorComponents.hue,
                saturation: colorComponents.saturation,
                brightness: colorComponents.brightness,
                alpha: colorComponents.alpha
            )
        }
        set {
            colorComponents = EFRGB2HSB(rgb: EFRGBColorComponents(color: newValue))
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.ef_baseInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.ef_baseInit()
    }
    
    // MARK:- Private methods
    private func ef_baseInit() {
        colorWheel = EFColorWheelView.init(frame: bounds)
        self.addSubview(colorWheel)

        colorWheel.addTarget(
            self, action: #selector(ef_colorDidChangeValue(sender:)), for: UIControl.Event.valueChanged
        )
    }

    @objc private func ef_colorDidChangeValue(sender: EFColorWheelView) {
        colorComponents.hue = sender.hue
        colorComponents.saturation = sender.saturation
        self.delegate?.colorView(colorView: self, didChangeColor: self.color)
    }

    
}
