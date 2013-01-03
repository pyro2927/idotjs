//
//  ViewController.m
//  dotjs
//
//  Created by Joseph Pintozzi on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "ConciseKit.h"
#import "CHDropboxSync.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize syncer;

-(void)link{
	[NSThread sleepForTimeInterval:2.0];
	if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] link];
    } else {
        self.syncer = $new(CHDropboxSync);
        self.syncer.delegate = self;
//        [self.syncer doSync];
	}
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

//allow sync from shake
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (event.type == UIEventSubtypeMotionShake){
        [self.syncer doSync];
    }
}

// Delegate callback from the syncer. You can dealloc it now.
- (void)syncComplete {
    NSLog(@"Sync complete");
}

-(void)loadJavascriptFromFilepath:(NSString*)filePath{
    NSLog(@"Loading JS from file: %@", filePath);
    NSString *js = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSString *wrappedJs = [NSString stringWithFormat:@"$(document).ready(function() { %@; });", js];
	[embeddedWebView stringByEvaluatingJavaScriptFromString:wrappedJs];
}

-(void)checkJsForDomain:(NSString*)urlString{
    NSArray *parts = [urlString $split:@"."];
    if ([parts count] > 2) {
        NSString *secondLevelDomain = [NSString stringWithFormat:@"%@.%@", [parts $at:[parts count] - 2], [parts $last]];
        [self checkJsForDomain:secondLevelDomain];
    }
	NSString *jsFile = [NSString stringWithFormat:@"%@/%@.js", [$ documentPath], urlString];
    if ([[NSFileManager defaultManager] fileExistsAtPath:jsFile]) {
        [self loadJavascriptFromFilepath:jsFile];
    }
}

-(void)checkJsForUrl:(NSString*)urlString{
    NSString *jsFile = [[$ documentPath] $append:@"/default.js"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:jsFile]) {
        [self loadJavascriptFromFilepath:jsFile];
    }
    [self checkJsForDomain:urlString];
}

#pragma mark UIWebView methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    requestUrlString = [[request URL] absoluteString];
    if (![requestUrlString isEqualToString:@"about:blank"] && ![oldUrlString isEqualToString:requestUrlString]) {
        newPageLoad = YES;
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    loadBalance++;
    [refreshButton setImage:[UIImage imageNamed:@"46-no"]];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    loadBalance--;
    if (loadBalance == 0 && newPageLoad && ![oldUrlString isEqualToString:[[webView.request URL] absoluteString]]) {
        newPageLoad = NO;
        NSString *loadedHost = [[webView.request URL] host];
        oldUrlString = [[webView.request URL] absoluteString];
        NSLog(@"Finished Loading %@", [[webView.request URL] absoluteString]);
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"jquery-1.8.3.min" ofType:@"js"];
        NSData *jquery = [NSData dataWithContentsOfFile:filePath];
        NSString *jqueryString = [[NSMutableString alloc] initWithData:jquery encoding:NSUTF8StringEncoding];
        [webView stringByEvaluatingJavaScriptFromString:jqueryString];
        [self checkJsForUrl:loadedHost];
    }
    
//    change our stop icon to refresh
    if (![webView isLoading]) {
        [refreshButton setImage:[UIImage imageNamed:@"01-refresh"]];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    loadBalance--;
}

#pragma IBActions to handle webview stuff
-(IBAction)reloadWebView:(id)sender{
    if ([embeddedWebView isLoading]) {
        [embeddedWebView stopLoading];
        [refreshButton setImage:[UIImage imageNamed:@"01-refresh"]];
    } else {
        [embeddedWebView reload];
        [refreshButton setImage:[UIImage imageNamed:@"46-no"]];
        oldUrlString = @"";
    }
}
-(IBAction)goBack:(id)sender{
    [embeddedWebView goBack];
}
-(IBAction)goForward:(id)sender{
    [embeddedWebView goForward];
}

-(IBAction)showOptions:(id)sender{
    UIActionSheet *options = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Enter URL", nil];
    [options showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"URL" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Go", nil];
            [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [alertView show];
            break;
        }
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex != alertView.cancelButtonIndex){
        NSMutableString *urlString = [NSMutableString stringWithString:[[alertView textFieldAtIndex:0] text]];
        if (![urlString hasPrefix:@"http"]) {
            [urlString $prepend_:@"http://"];
        }
        [embeddedWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    }
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:YES];
	[NSThread detachNewThreadSelector:@selector(link) toTarget:self withObject:nil];
}

- (void)viewDidLoad{
    [super viewDidLoad];
//    set an initial load balance of 0
    loadBalance = 0;
    
//    go back swipe
    UISwipeGestureRecognizer *swiper = [[UISwipeGestureRecognizer alloc] initWithTarget:embeddedWebView action:@selector(goBack)];
    [swiper setDirection:UISwipeGestureRecognizerDirectionRight];
    [swiper setNumberOfTouchesRequired:2];
    [embeddedWebView addGestureRecognizer:swiper];
//    go forward swipe
    swiper = [[UISwipeGestureRecognizer alloc] initWithTarget:embeddedWebView action:@selector(goForward)];
    [swiper setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swiper setNumberOfTouchesRequired:2];
    [embeddedWebView addGestureRecognizer:swiper];
    
	[embeddedWebView setDelegate:self];
	[embeddedWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
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
