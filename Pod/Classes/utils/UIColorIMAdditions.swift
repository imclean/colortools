//
//  UIColorIMAdditions.swift
//  ColourTools
//
//  Created by Iain McLean on 11/09/2015.
//  Copyright (c) 2015 brightskyapps. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    func luminance () -> CGFloat {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        if self.getRed(&r,green: &g,blue: &b,alpha: &a){
            return (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
        } else {
            return 0
        }
    }
    
    func isDarkColor () -> Bool {
        if (self.luminance()<0.5){
            return true
        } else {
            return false
        }
    }
    
    func isBlackOrWhite () -> Bool {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        if self.getRed(&r,green: &g,blue: &b,alpha: &a){
            if (r > 0.91 && g > 0.91 && b > 0.91){
                return true
            }
            if (r < 0.09 && g < 0.09 && b < 0.09){
                return true
            }
            return false
        } else {
            return false
        }
    }
    
    func isDistinct (color:UIColor) -> Bool {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        var rc:CGFloat = 0
        var gc:CGFloat = 0
        var bc:CGFloat = 0
        var ac:CGFloat = 0
        
        let threshold:CGFloat = 0.25
        if self.getRed(&r,green: &g,blue: &b,alpha: &a){
            if color.getRed(&rc,green: &gc,blue: &bc,alpha: &ac){
                if (fabs(r - rc) > threshold || fabs(g - gc) > threshold || fabs(b - bc) > threshold || fabs(a - ac) > threshold) {
                        // Check for grays
                        if ( fabs(r - g) < 0.03 && fabs(r - b) < 0.03) {
                            if ( fabs(rc - gc) < 0.03 && fabs(rc - bc) < 0.03){
                                return false
                            }
                        }
                        return true
                }
            }
        }
        return false
    }
    
    func isContrastingColour (color:UIColor) -> Bool {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        var rc:CGFloat = 0
        var gc:CGFloat = 0
        var bc:CGFloat = 0
        var ac:CGFloat = 0
        
        var contrast:CGFloat = 0
        if self.getRed(&r,green: &g,blue: &b,alpha: &a){
            if color.getRed(&rc,green: &gc,blue: &bc,alpha: &ac){
                if (self.luminance() > color.luminance()){
                    contrast = (self.luminance() + 0.05) / (color.luminance() + 0.05)
                } else {
                    contrast = (self.luminance() + 0.05) / (color.luminance() + 0.05)
                }
            }
        }
        return contrast > 1.6
    }
    
    func colorWithMinimumSaturation(saturation:CGFloat) -> UIColor {
        var h:CGFloat = 0
        var s:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        if (s < saturation){
            return UIColor(hue: h, saturation: s, brightness: b, alpha: a)
        } else {
            return self
        }
    }
    
    class func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if (cString.hasPrefix("0x")) {
            cString = (cString as NSString).substringFromIndex(2)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    public func toHexString() -> NSString {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"0x%06x", rgb)
    }
}
