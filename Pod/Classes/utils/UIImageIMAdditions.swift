//
//  UIImageIMAdditions.swift
//  ColourTools
//
//  Created by Iain McLean on 11/09/2015.
//  Copyright (c) 2015 brightskyapps. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func colorHexFrom(x:Int, y:Int) -> NSString{
        let imageRef:CGImageRef = self.CGImage!
        let width:Int  = CGImageGetWidth(imageRef)
        let height:Int  = CGImageGetHeight(imageRef)
        let colourSpace = CGImageGetColorSpace(imageRef)
        let rawData = UnsafeMutablePointer<CUnsignedChar>(malloc(width * height * 4))
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo = CGBitmapInfo(rawValue:CGImageAlphaInfo.PremultipliedLast.rawValue | CGBitmapInfo.ByteOrder32Big.rawValue)
        let context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colourSpace,bitmapInfo.rawValue)
        let frame = CGRectMake(CGFloat(0.0), CGFloat(0.0), CGFloat(width),CGFloat(height))
        CGContextDrawImage(context,frame, imageRef)
        
        let byteIndex:Int = (bytesPerRow * y)+(x * bytesPerPixel)
        
    
        let red = (rawData[byteIndex])
        let green = (rawData[byteIndex+1])
        let blue = (rawData[byteIndex+2])
        free(rawData)
        
        return NSString(format:"#%02X%02X%02X", red,green,blue)
    }
    
    func colorFromImage(x:Int,y:Int) -> UIColor! {
        let imageRef:CGImageRef = self.CGImage!
        let width:Int  = CGImageGetWidth(imageRef)
        let height:Int  = CGImageGetHeight(imageRef)
        let colourSpace = CGImageGetColorSpace(imageRef)
        let rawData = UnsafeMutablePointer<CUnsignedChar>(malloc(width * height * 4))
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo = CGBitmapInfo(rawValue:CGImageAlphaInfo.PremultipliedLast.rawValue | CGBitmapInfo.ByteOrder32Big.rawValue)
        let context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colourSpace, bitmapInfo.rawValue)
        let frame = CGRectMake(CGFloat(0.0), CGFloat(0.0), CGFloat(width),CGFloat(height))
        CGContextDrawImage(context,frame, imageRef)
        
        let byteIndex:Int = (bytesPerRow * y)+(x * bytesPerPixel)
        
        let red:CGFloat   = CGFloat(rawData[byteIndex])  / 255.0
        let green:CGFloat = CGFloat(rawData[byteIndex + 1])  / 255.0
        let blue:CGFloat  = CGFloat(rawData[byteIndex + 2])  / 255.0
        let alpha:CGFloat = CGFloat(rawData[byteIndex + 3]) / 255.0
        free(rawData);
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func imageScaledToSize(size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0);
        self.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    func imageByScalingProprtionallyToSize(targetSize:CGSize) -> UIImage {
        let sourceImage = self
        var newImage:UIImage?
        
        let imageSize = sourceImage.size
        let width:CGFloat = imageSize.width
        let height:CGFloat = imageSize.height
        
        let targetWidth:CGFloat = targetSize.width
        let targetHeight:CGFloat = targetSize.height
        
        var scaleFactor:CGFloat = 0.0
        var scaledWidth:CGFloat = targetWidth
        var scaledHeight:CGFloat = targetHeight
        
        var thumbnailPoint = CGPointMake(0.0, 0.0)
        
        if(CGSizeEqualToSize(imageSize, targetSize) == false){
            let widthFactor:CGFloat = targetWidth / width
            let heightFactor:CGFloat = targetHeight / height
            
            if(widthFactor < heightFactor){
                scaleFactor = widthFactor
            }else{
                scaleFactor = heightFactor
            }
            
            scaledWidth = width * scaleFactor
            scaledHeight = height * scaleFactor
            
            if (widthFactor < heightFactor){
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
            } else if (widthFactor > heightFactor){
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
            }
        }
        UIGraphicsBeginImageContext(targetSize)
        
        var thumbnailRect = CGRectZero
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width  = scaledWidth
        thumbnailRect.size.height = scaledHeight
        
        sourceImage.drawInRect(thumbnailRect)
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if(newImage == nil){
            print("could not scale image");
        }
        return newImage!
    }
}