//
//  ViewController.swift
//  CoreML-samples
//
//  Created by Yuta Akizuki on 2017/06/23.
//  Copyright © 2017年 ytakzk. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var probsLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // Deep Residual Learning for Image Recognition
    // https://arxiv.org/abs/1512.03385
    let resnetModel = Resnet50()
    let mnistModel  = SimpleMnist()
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.text = ""
        probsLabel.text  = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        imagePicker.delegate   = self
        imagePicker.sourceType = .photoLibrary

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openPhotoLibrary(_ sender: Any) {
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func predict(_ sender: Any) {
        
        switch (segmentedControl.selectedSegmentIndex) {
            
        case 0:
            
            guard let image = imageView.image, let ref = image.buffer else {
                    
                    return
            }
            
            resnet(ref: ref)
            
        default:
            
            guard let image = imageView.image,
                let resized = image.resize(size: CGSize(width: 28, height: 28)),
                let ref = resized.grayscaledBuffer else {
                    
                return
            }
            
            mnist(ref: ref)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The input image size should be 224x224 for ResNet
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let resized = image.resize(size: CGSize(width: 224, height: 224)) else {
                
                return
        }
        
        imageView.image  = resized
        resultLabel.text = ""
        probsLabel.text  = ""
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

private extension ViewController {
    
    func resnet(ref: CVPixelBuffer) {
        
        do {
            
            // prediction
            let output = try resnetModel.prediction(image: ref)
            
            // sort classes by probability
            let sorted = output.classLabelProbs.sorted(by: { (lhs, rhs) -> Bool in
                
                return lhs.value > rhs.value
            })
            
            resultLabel.text = output.classLabel
            probsLabel.text  = "\(sorted[0].key): \(NSString(format: "%.2f", sorted[0].value))\n\(sorted[1].key): \(NSString(format: "%.2f", sorted[1].value))\n\(sorted[2].key): \(NSString(format: "%.2f", sorted[2].value))\n\(sorted[3].key): \(NSString(format: "%.2f", sorted[3].value))\n\(sorted[4].key): \(NSString(format: "%.2f", sorted[4].value))"
            
            print(output.classLabel)
            print(output.classLabelProbs)
            
        } catch {
            
            print(error)
        }
    }
    
    func mnist(ref: CVPixelBuffer) {
        
        // prediction
        
        do {
            
            let output = try mnistModel.prediction(input: ref)
            
            // sort classes by probability
            let sorted = output.probs.sorted(by: { (lhs, rhs) -> Bool in
                
                return lhs.value > rhs.value
            })
            
            resultLabel.text = output.predictedNumber
            probsLabel.text  = "\(sorted[0].key): \(NSString(format: "%.2f", sorted[0].value))\n\(sorted[1].key): \(NSString(format: "%.2f", sorted[1].value))\n\(sorted[2].key): \(NSString(format: "%.2f", sorted[2].value))\n\(sorted[3].key): \(NSString(format: "%.2f", sorted[3].value))\n\(sorted[4].key): \(NSString(format: "%.2f", sorted[4].value))"
            
            print(output.predictedNumber)
            print(output.probs)
            
        } catch {
            
            print(error)
        }
    }
}
