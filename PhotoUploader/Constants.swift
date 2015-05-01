/*
* Copyright 2010-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

import Foundation

//WARNING: To run this sample correctly, you must set the following constants.
let CognitoRegionType = AWSRegionType.USEast1  // e.g. AWSRegionType.USEast1
let DefaultServiceRegionType = AWSRegionType.USWest1 // e.g. AWSRegionType.USEast1
let CognitoIdentityPoolId = "us-east-1:77c043dd-d7b4-44b5-821c-c31199a265fe"
let S3BucketName = "bucket-for-testing"
let ARNUnauthRole = "arn:aws:iam::930197279879:role/Cognito_testUnauth_DefaultRole"
let ARNAuthRole = "arn:aws:iam::930197279879:role/Cognito_testAuth_DefaultRole"
