//
//  TurtleViewController.h
//  iturtle
//
//  Created by John McLaughlin on 4/7/10.
//  Copyright 2010 Loghound.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TurtleView.h"
#import "LogoParser.h"



@interface TurtleViewController : UIViewController {
	IBOutlet TurtleView *outputView;
	LogoParser *parser;
	IBOutlet UITextView *debugView;
	IBOutlet UITextView *inputView;
	NSTimer *timer;
	CGFloat frequency;
	IBOutlet UIView *debugParentView;
	IBOutlet UIView *textViewsParent;
	BOOL errorWindowCollapsed;
	IBOutlet UIButton *startButton;
	IBOutlet UIButton *stopButton;
	UIPopoverController *popController;

}

@property (nonatomic, retain) IBOutlet UIButton *startButton;;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;
@property (nonatomic, retain) IBOutlet TurtleView *outputView;
@property (nonatomic, retain) LogoParser *parser;
@property (nonatomic, retain) 	IBOutlet UITextView *debugView;
@property (nonatomic, retain) 	IBOutlet UITextView *inputView;
@property (retain) IBOutlet UIView *debugParentView;
@property (retain) IBOutlet UIView *textViewsParent;
@property (assign) CGFloat frequency;
@property (retain) UIPopoverController * popController;
-(IBAction) doIt:(id) sender;
- (IBAction)run:(id)sender;
- (IBAction)stop:(id)sender;
-(IBAction) fullScreen:(id) sender ;
-(IBAction) toggleErrorScreen:(id) sender;
-(IBAction) toggleHelp:(id) sender;
@end
