//
//  EditScriptViewController.m
//  dotjs
//
//  Created by Joseph Pintozzi on 1/3/13.
//
//

#import "EditScriptViewController.h"
#import "ConciseKit.h"

@interface EditScriptViewController ()

@end

@implementation EditScriptViewController
@synthesize scriptName;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)keyboardDidShow: (NSNotification *) notif{
    NSValue *value = [[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [value CGRectValue];
    CGRect oldFrame = scriptTextView.frame;
    [UIView animateWithDuration:.25f animations:^{
        [scriptTextView setFrame:CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height - keyboardFrame.size.height)];
    }];
}

- (void)keyboardDidHide: (NSNotification *) notif{
    NSValue *value = [[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [value CGRectValue];
    CGRect oldFrame = scriptTextView.frame;
    [UIView animateWithDuration:.25f animations:^{
        [scriptTextView setFrame:CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height + keyboardFrame.size.height)];
    }];
}

-(void)save{
    NSString *fullFilePath = [[[$ documentPath] $append:@"/"] $append:scriptName];
    [scriptTextView.text writeToFile:fullFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    scriptTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height)];
    [self.view addSubview:scriptTextView];
    [scriptTextView setKeyboardType:UIKeyboardTypeASCIICapable];
    [scriptTextView setReturnKeyType:UIReturnKeyDefault];
    [scriptTextView setDelegate:self];
    
//    detect when our keyboard is shown/hidden
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    NSString *fullFilePath = [[[$ documentPath] $append:@"/"] $append:scriptName];
    NSString *js = [NSString stringWithContentsOfFile:fullFilePath encoding:NSUTF8StringEncoding error:nil];
    [scriptTextView setText:js];
    [self setTitle:scriptName];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
