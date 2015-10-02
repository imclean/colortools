//
//  IMImageColors.swift
//  ColourTools
//
//  Created by Iain McLean on 11/09/2015.
//  Copyright (c) 2015 brightskyapps. All rights reserved.
//

import Foundation
import UIKit

public typealias ImageDetectionCompletion = (colorArray:[UIColor]?, error : NSError?) -> Void

public class IMCountedColour : Equatable  {
    var count:Int
    var colour:UIColor
    
    init(count:Int, colour:UIColor){
        self.count = count
        self.colour = colour
    }
}


public class IMImageColours: NSObject {
    
    var colours:[UIColor]
    var count:Int
    var scaledImage:UIImage?
    var kColorThresholdMinimumPercentage:CGFloat = 0.01
    var IMIMAGECOLORS_SCALED_SIZE = 50.0
    var vibeMax:Float = 0
    
    public init(image:UIImage!,count:Int){
        self.count = count
        self.colours = [UIColor]()
        if let inputImage = image {
            var ratio:CGFloat = 1
            var targetSize = inputImage.size
            
            if(inputImage.size.width > inputImage.size.height){
                ratio = inputImage.size.width / inputImage.size.height
                targetSize = CGSizeMake(50 * ratio, 50)
            }else if(inputImage.size.width < inputImage.size.height){
                ratio = inputImage.size.height / inputImage.size.width
                targetSize = CGSizeMake(50, ratio * 50)
            }
            self.scaledImage = inputImage.imageByScalingProprtionallyToSize(targetSize)
        }
    }
    
    public func detectColorsFromImage(completion:ImageDetectionCompletion) -> Void {
        if(self.scaledImage==nil || self.count == 0){
            completion(colorArray: nil ,error: NSError(domain: "IMImageDetectionDomain", code: 400, userInfo: nil))
            return;
        }
        let imageColors:NSCountedSet = NSCountedSet()
        var finalColors:[UIColor] = [UIColor]();
        finalColors.appendContentsOf(self.detectColorsOfImageWithColors(imageColors))
        while (finalColors.count < self.count){
            finalColors.append(UIColor.whiteColor())
        }
        self.colours.appendContentsOf(finalColors)
        completion(colorArray: self.colours,error: nil)
    }
    
    func getDiff(a:Float,b:Float) -> Float {
        //// ---- GET DIFFERENCE BETWEEN A + B VALUES ----
        return abs(a-b)
    }
    
    func maxThree(a:Float,b:Float,c:Float) -> Float {
        ///--- COMPARE A, B, C AND RETURN HIGHEST ---
        if(a > b) {
            if(a > c) {
                return a
            } else {
                return c
            }
        } else {
            if(b > c)     {
                return b
            } else {
                return c
            }
        }
    }
    
    func detectColorsOfImageWithColors(colors:NSCountedSet?) -> [UIColor] {
        let width:size_t  = CGImageGetWidth(self.scaledImage!.CGImage)
        let height:size_t  = CGImageGetHeight(self.scaledImage!.CGImage)
        
        let imageColors:NSCountedSet  = NSCountedSet(capacity: width * height)
        
        
        for (var i:Int = 0; i < width; i++){
            for (var j:Int = 0; j < height; j++){
                let colour:UIColor = self.scaledImage!.colorFromImage(i, y:j)
                var red:CGFloat = 0
                var green:CGFloat = 0
                var blue:CGFloat = 0
                var alpha:CGFloat = 0
                if colour.getRed(&red, green: &green, blue: &blue, alpha:&alpha){
                    let vRG:Float = getDiff(Float(red*255),b:Float(green*255))
                    let vRB:Float = getDiff(Float(red*255),b:Float(blue*255))
                    let vGB:Float = getDiff(Float(green*255),b:Float(blue*255))
                    if(((red*255 + green*255 + blue*255) < 720) && (vRG > 10 || vRB > 10 || vGB > 10)){
                        var thisVMax:Float = vRG
                        thisVMax = maxThree(vRG,b: vRB,c: vGB)
                        if(thisVMax > self.vibeMax) {
                            self.vibeMax = thisVMax
                            imageColors.addObject(colour)
                        }
                    }
                }
            }
        }
        let enumerator = imageColors.objectEnumerator()
        var curColor:UIColor
        var sortedColours:[IMCountedColour] =  [IMCountedColour]()
        var resultColours:[UIColor] = [UIColor]()
        
        while let anotherColour:UIColor = enumerator.nextObject() as? UIColor {
            curColor = anotherColour.colorWithMinimumSaturation(0.15)
            let colourCount:Int =  imageColors.countForObject(curColor)
            let countedColour:IMCountedColour = IMCountedColour(count: colourCount, colour: curColor)
            sortedColours.append(countedColour)
        }
        
        sortedColours.sortInPlace({ $0.count < $1.count })
        
        
        for countedColour in sortedColours {
            let col:IMCountedColour = countedColour
            curColor = col.colour
            var continueFlag:Bool = false
            for c in resultColours {
                if (curColor.isDistinct(c)){
                    continueFlag = true
                    break
                }
            }
            if (continueFlag){
                continue
            }
            if (resultColours.count < self.count){
                resultColours.append(curColor)
            }
        }
        return resultColours
    }
}

public func ==(lhs: IMCountedColour, rhs: IMCountedColour) -> Bool {
    return lhs.count == rhs.count
}

public func <(lhs: IMCountedColour, rhs: IMCountedColour) -> Bool {
    return lhs.count < rhs.count
}

public func >(lhs: IMCountedColour, rhs: IMCountedColour) -> Bool {
    return lhs.count > rhs.count
}
