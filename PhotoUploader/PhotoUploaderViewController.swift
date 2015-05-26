//
//  PhotoUploaderViewController.swift
//  PhotoUploader
//
//  Created by Justin Cano on 4/22/15.
//  Copyright (c) 2015 bumrush. All rights reserved.
//

import UIKit
import MobileCoreServices
import AssetsLibrary

class PhotoUploaderViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var cognitoIdentityId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        cognitoIdentityId = appDelegate.cognitoIdentityId
        println("\(cognitoIdentityId!)")
    }
    
    // MARK: - UI Methods
    
    @IBAction func viewPhotosFromAWS(sender: UIButton) {
//        let collectionView = AWSPhotoCollectionViewController()
//        collectionView.delegate = self
//        presentViewController(collectionView, animated: true, completion: nil)
        
        let downloadingFilePath = NSTemporaryDirectory().stringByAppendingPathComponent("downloaded-object")
        let downloadingFileURL = NSURL.fileURLWithPath(downloadingFilePath)
        
        let request: AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
        request.bucket = S3BucketName
        request.key = "users/\(cognitoIdentityId!)/test-object"
//        request.key = "test-object"
        request.downloadingFileURL = downloadingFileURL
//        let listObjectsRequest: AWSS3ListObjectsRequest = AWSS3ListObjectsRequest()
//        listObjectsRequest.bucket = S3BucketName
//        listObjectsRequest.prefix = "users/" + cognitoIdentityId!
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        transferManager.download(request).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { [unowned self] (task) -> AnyObject! in
            if task.error != nil {
                println("\(task.error)")
            } else {
                if let downloadOutput = task.result as? AWSS3TransferManagerDownloadOutput {
                    let myCIImage = CIImage(contentsOfURL: downloadOutput.body as! NSURL)
                    let image = UIImage(CIImage: myCIImage)
                    self.imageView.image = image
                    self.updateUI()
                    println("\(downloadOutput.body)")
                }
            }
            return nil
        })
//        transferManager.download(request).continueWithBlock { [unowned self] (task) -> AnyObject! in
//            if task.error != nil {
//                println("\(task.error)")
//            } else {
//                let image = UIImage(contentsOfFile: downloadingFilePath)
//                self.imageView.image = image
//                println("\(task.result)")
//            }
//            return nil
//        }

        
        let listOjbectsOutput: AWSS3ListObjectsOutput = AWSS3ListObjectsOutput()
        
        var objectSummaries = listOjbectsOutput.contents
//        println("\(objectSummaries)")
    }

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
        imageView.image = image
        makeRoomForImage()
        
        //save image to app's temp folder
        let path = NSTemporaryDirectory().stringByAppendingPathComponent("upload-image.tmp")
        let imageData = UIImagePNGRepresentation(image)
        imageData.writeToFile(path, atomically: true)
        
//        let imageURL = NSURL(string: path)
        let imageURL = NSURL(fileURLWithPath: path)
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket = S3BucketName
        uploadRequest.key = "users/\(cognitoIdentityId!)/test-object"
        uploadRequest.body = imageURL
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        transferManager.upload(uploadRequest).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            if task.error != nil {
                println("\(task.error)")
                println("Error uploading: \(imageURL)")
            } else {
                println("Upload completed!")
            }
            return nil
        })

        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Helper Methods
    
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
}

extension UIImage {
    var aspectRatio:CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}