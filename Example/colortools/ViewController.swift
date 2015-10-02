//
//  ViewController.swift
//  colortools
//
//  Created by Iain McLean on 10/02/2015.
//  Copyright (c) 2015 Iain McLean. All rights reserved.
//

import UIKit
import colortools

class ViewController: UIViewController , UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var contrastingView: UIView!
    @IBOutlet var vibLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    var backGroundVibrant:UIColor = UIColor.clearColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imageView.userInteractionEnabled = true
        let tapp:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("selectImageFromLibrary"))
        imageView.addGestureRecognizer(tapp)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectImageFromLibrary(){
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .PhotoLibrary
        presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.clipsToBounds = true
            imageView.contentMode = .ScaleAspectFit
            imageView.image = pickedImage
            self.processImage(pickedImage)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func processImage(image:UIImage) {
        let colorManager:IMImageColours = IMImageColours(image: image, count: 1)
        colorManager.detectColorsFromImage({ (colorArray, error) -> Void in
            print(colorArray)
            if let array = colorArray {
                let myColour = array[0]
                self.contrastingView.backgroundColor = myColour
                self.vibLabel.text = myColour.toHexString() as String
            }
        })
    }
}

