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

}
@property (nonatomic, retain) IBOutlet TurtleView *outputView;
@property (nonatomic, retain) LogoParser *parser;
@property (nonatomic, retain) 	IBOutlet UITextView *debugView;
@property (nonatomic, retain) 	IBOutlet UITextView *inputView;
@property (assign) CGFloat frequency;
-(IBAction) doIt:(id) sender;
- (IBAction)run:(id)sender;
- (IBAction)stop:(id)sender;
@end
