//
//  ViewController.swift
//  CoreML-samples
//
//  Created by Yuta Akizuki on 2017/06/23.
//  Copyright © 2017年 ytakzk. All rights reserved.
//

import UIKit

extension UIImage {
    
    func buffer() -> CVPixelBuffer? {
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        
        guard status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    func grayscaledBuffer() -> CVPixelBuffer? {
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_OneComponent8, attrs, &pixelBuffer)
        
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let grayColorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: grayColorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    func resize(size: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContext(CGSize(width: size.width, height: size.height))
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    var grayscaled: UIImage? {
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 0,
                                space: CGColorSpaceCreateDeviceGray(),
                                bitmapInfo: CGImageAlphaInfo.none.rawValue)
        
        guard let ctx = context, let cgImage = cgImage else {
            
            return nil
        }
        
        ctx.draw(cgImage, in: rect)
        
        guard let image = ctx.makeImage() else { return nil }
        
        return UIImage(cgImage: image)
    }
    
    func grayscaledPixels() -> [CGFloat]? {
        
        guard let cgImage = self.cgImage else { return nil }
        
        let size     = self.size
        let dataSize  = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context    = CGContext(data: &pixelData,
                                   width: Int(size.width),
                                   height: Int(size.height),
                                   bitsPerComponent: 8,
                                   bytesPerRow: 4 * Int(size.width),
                                   space: colorSpace,
                                   bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        var result: [CGFloat] = []
        
        for i in stride(from: 0, to: pixelData.count, by: 4) {
            
            let val = (CGFloat(pixelData[i]) + CGFloat(pixelData[i+1]) + CGFloat(pixelData[i+2])) / (255.0 * 3.0)
            
            result.append(val)
        }
        
        return result
    }
}
