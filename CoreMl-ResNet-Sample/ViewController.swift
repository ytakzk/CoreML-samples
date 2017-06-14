//
//  ViewController.swift
//  CoreMl-ResNet-Sample
//
//  Created by yakizuki on 2017/06/13.
//  Copyright © 2017年 ytakzk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var probsLabel: UILabel!
    
    // Deep Residual Learning for Image Recognition
    // https://arxiv.org/abs/1512.03385
    let model = Resnet50()
    
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
        
        guard let image = imageView.image,
            let ref = image.buffer() else {
                
                return
        }
        
        do {
            
            // prediction
            let output = try model.prediction(image: ref)
            
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
