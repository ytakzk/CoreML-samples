# CoreML-samples

This is the sample code for Core ML using ResNet50 provided by [Apple](https://developer.apple.com/machine-learning/).  
[ResNet50](https://arxiv.org/abs/1512.03385) can categorize the input image to 1000 pre-trained categories.  
What's more, this includes a sample code for coremltools converting keras model to mlmodel.

<img src="./demo.png" alt="demo" title="demo" width="300">

## Source Code for the prediction 
```
guard let image = imageView.image, let ref = image.buffer() else {

        return
}

do {

    // predict
    let output = try model.prediction(image: ref)

    print(output.classLabel)
    print(output.classLabelProbs)

} catch {

    print(error)
}
```
