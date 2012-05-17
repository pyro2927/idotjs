//
//  ViewController.m
//  dotjs
//
//  Created by Joseph Pintozzi on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

-(void)link{
	[NSThread sleepForTimeInterval:2.0];
	if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] link];
    } else {
		[[self restClient] performSelectorOnMainThread:@selector(loadMetadata:) withObject:@"/dotjs" waitUntilDone:YES];
	}
}

-(void)loadJavascriptFromFilepath:(NSString*)filePath{
	[(UIWebView*)self.view stringByEvaluatingJavaScriptFromString:[[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]];
}

#pragma mark DropboxAPI methods
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
	
    if (metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
		for (DBMetadata *file in metadata.contents) {
			NSLog(@"\t%@", file.filename);
		}
    }
	[[NSUserDefaults standardUserDefaults] setObject:folderData forKey:@"folderdata"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	folderData = metadata;
	[self checkJsForUrl:[[((UIWebView*)self.view).request URL] host]];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
	
    NSLog(@"Error loading metadata: %@", error);
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    NSLog(@"File loaded into path: %@", localPath);
	[self loadJavascriptFromFilepath:localPath];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    NSLog(@"There was an error loading the file - %@", error);
}

-(void)checkJsForUrl:(NSString*)urlString{
	NSArray *savePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSMutableString *savePath = [NSMutableString stringWithString:[savePaths objectAtIndex:0]];
	if (folderData == NULL) {
		folderData = [[NSUserDefaults standardUserDefaults] objectForKey:@"folderdata"];
	}
	//see if we can find a file that matches!
	for (DBMetadata *file in folderData.contents) {
		if ([file.filename hasPrefix:urlString]) {
			//we've found a matching file!
			[savePath appendFormat:@"/%@",file.filename];
			if ([[NSFileManager defaultManager] fileExistsAtPath:savePath isDirectory:NO]) {
				[self loadJavascriptFromFilepath:savePath];
			} else {
				[[self restClient] loadFile:file.path intoPath:savePath];
			}
		}
	}
}

#pragma mark UIWebView methods
- (void)webViewDidFinishLoad:(UIWebView *)webView{
	NSString *loadedHost = [[webView.request URL] host];
	[self checkJsForUrl:loadedHost];
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:YES];
	[NSThread detachNewThreadSelector:@selector(link) toTarget:self withObject:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[(UIWebView*)self.view setDelegate:self];
	[(UIWebView*)self.view loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
}

- (DBRestClient*)restClient {
    if (restClient == nil) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

@end
