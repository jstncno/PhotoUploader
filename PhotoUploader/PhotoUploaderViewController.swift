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
    
    private func updateUI() {
        makeRoomForImage()
    }
    
    // MARK: - Image
    
    var imageView = UIImageView()
    @IBOutlet weak var imageViewContainer: UIView! {
        didSet {
            imageViewContainer.addSubview(imageView)
        }
    }
    
    // MARK: - Delegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject] ) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        //process image
//        let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket = "bucket-for-testing"
        uploadRequest.key = "chelsea-grad.jpg"
//        uploadRequest.body = imageURL
//        
//        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
//        transferManager.upload(uploadRequest).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
//            if task.error != nil {
//                println("\(task.error)")
//                println("Error uploading: \(imageURL)")
//            } else {
//                println("Upload completed!")
//            }
//            return nil
//        })
        
        
        
        if let uploadFilePath = NSBundle.mainBundle().URLForResource("chelsea-grad", withExtension: "jpg") {
            uploadRequest.body = uploadFilePath
            println("\(uploadFilePath)")
            
            if let imgData = NSData(contentsOfURL: uploadFilePath) {
                if let img = UIImage(data: imgData) {
                    println("img added")
                    imageView.image = img
                    makeRoomForImage()
                }
            }
            
            let transferManager = AWSS3TransferManager.defaultS3TransferManager()
            transferManager.upload(uploadRequest).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
                if task.error != nil {
                    println("\(task.error)")
                    println("Error uploading: \(uploadFilePath)")
                } else {
                    println("Upload completed!")
                }
                return nil
            })
        }

//        println("\(imageURL)")
        

        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func makeRoomForImage() {
        var extraHeight:CGFloat = 0
        if imageView.image?.aspectRatio > 0 {
            if let width = imageView.superview?.frame.size.width {
                let height = width / imageView.image!.aspectRatio
                extraHeight = height - imageView.frame.height
                imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            }
        } else {
            extraHeight = -imageView.frame.height
            imageView.frame = CGRectZero
        }
        preferredContentSize = CGSize(width: preferredContentSize.width, height: preferredContentSize.height + extraHeight)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

extension UIImage {
    var aspectRatio:CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}