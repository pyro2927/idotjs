//
//  ViewController.h
//  dotjs
//
//  Created by Joseph Pintozzi on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
@interface ViewController : UIViewController<DBRestClientDelegate, UIWebViewDelegate>{
	DBRestClient* restClient;
	DBMetadata *folderData;
}

@end
