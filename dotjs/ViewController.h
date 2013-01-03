//
//  ViewController.h
//  dotjs
//
//  Created by Joseph Pintozzi on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "CHDropboxSync.h"

@interface ViewController : UIViewController<DBRestClientDelegate, UIWebViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>{
	DBRestClient* restClient;
	DBMetadata *folderData;
    int loadBalance;
    bool newPageLoad;
    NSString *oldUrlString;
    NSString *requestUrlString;
    IBOutlet UIWebView *embeddedWebView;
    IBOutlet UIBarButtonItem *refreshButton;
}

@property(retain) CHDropboxSync* syncer;

-(IBAction)reloadWebView:(id)sender;
-(IBAction)goBack:(id)sender;
-(IBAction)goForward:(id)sender;
-(IBAction)showOptions:(id)sender;

@end
