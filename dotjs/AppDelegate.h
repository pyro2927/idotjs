//
//  AppDelegate.h
//  dotjs
//
//  Created by Joseph Pintozzi on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, DBSessionDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
