//
//  EditScriptViewController.h
//  dotjs
//
//  Created by Joseph Pintozzi on 1/3/13.
//
//

#import <UIKit/UIKit.h>

@interface EditScriptViewController : UIViewController<UITextViewDelegate>{
    UITextView *scriptTextView;
    NSString *scriptName;
}

@property NSString *scriptName;

@end
