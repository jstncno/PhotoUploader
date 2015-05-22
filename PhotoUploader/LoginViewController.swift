//
//  LoginViewController.swift
//  PhotoUploader
//
//  Created by Justin Cano on 5/4/15.
//  Copyright (c) 2015 bumrush. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate
{
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            // User is already logged in, do work such as go to next view controller.
            performSegueWithIdentifier("Logged In", sender: self)
        }
        
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        self.view.addSubview(loginView)
        loginView.center = self.view.center
        loginView.readPermissions = ["public_profile", "email", "user_friends"]
        loginView.delegate = self
    }
    
    // MARK: - Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        performSegueWithIdentifier("Logged In", sender: loginButton)
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("logged out!")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Logged In":
                if let token = FBSDKAccessToken.currentAccessToken().tokenString {
                    let credentialsProvider:AWSCognitoCredentialsProvider = AWSCognitoCredentialsProvider(regionType: CognitoRegionType, identityPoolId: CognitoIdentityPoolId)
                    credentialsProvider.logins = ["graph.facebook.com": token]

                    let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
                    appDelegate.cognitoIdentityId = credentialsProvider.identityId

                    let defaultServiceConfiguration:AWSServiceConfiguration = AWSServiceConfiguration(region: DefaultServiceRegionType, credentialsProvider: credentialsProvider)
                    
                    AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
                }
                println("logged in!")
                
            default: break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
