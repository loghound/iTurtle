//
//  iturtleAppDelegate.h
//  iturtle
//
//  Created by John McLaughlin on 4/6/10.
//  Copyright Loghound.com 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TurtleView.h"
#import "LogoParser.h"

@interface iturtleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	IBOutlet TurtleView *outputView;
	LogoParser *parser;
	IBOutlet UITextView *debugView;
	IBOutlet UITextView *inputView;
	NSTimer *timer;
	CGFloat frequency;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TurtleView *outputView;
@property (nonatomic, retain) LogoParser *parser;
@property (nonatomic, retain) 	IBOutlet UITextView *debugView;
@property (nonatomic, retain) 	IBOutlet UITextView *inputView;
@property (assign) CGFloat frequency;
-(IBAction) doIt:(id) sender;
- (IBAction)run:(id)sender;
- (IBAction)stop:(id)sender;
@end

