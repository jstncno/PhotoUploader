//
//  PhotoUploaderViewController.swift
//  PhotoUploader
//
//  Created by Justin Cano on 4/22/15.
//  Copyright (c) 2015 bumrush. All rights reserved.
//

import UIKit
import MobileCoreServices

class PhotoUploaderViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBAction func choosePhoto(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            let picker = UIImagePickerController()
            picker.sourceType = .PhotoLibrary
            if let availableTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary) {
                picker.mediaTypes = [kUTTypeImage]
                picker.delegate = self
                //picker.allowsEditing = true
                presentViewController(picker, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Delegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject] ) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as! UIImage
        }
        //process image
        println("image picked!")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
}
