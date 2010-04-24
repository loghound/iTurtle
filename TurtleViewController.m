    //
//  TurtleViewController.m
//  iturtle
//
//  Created by John McLaughlin on 4/7/10.
//  Copyright 2010 Loghound.com. All rights reserved.
//

#import "TurtleViewController.h"
#import "HelpViewController.h"

@implementation TurtleViewController
@synthesize parser,outputView;
@synthesize debugView,inputView;
@synthesize frequency;
@synthesize debugParentView,textViewsParent;
@synthesize startButton,stopButton;
@synthesize popController;


-(void) saveProgram {
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	[defaults setObject:self.inputView.text forKey:@"turtle-program"];
	[defaults synchronize];
	
	
}
-(void) recallProgram {
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	NSString *defaultText;
	defaultText=[defaults valueForKey:@"turtle-program"];
	
	if (!defaultText) {
		NSString*defaultTextFile=[[NSBundle mainBundle]pathForResource:@"defaultTurtle" ofType:@"txt"];
		defaultText=[NSString stringWithContentsOfFile:defaultTextFile];
	} 
	self.inputView.text=defaultText;
	
}


-(IBAction) toggleHelp:(UIButton*) helpButton {
	HelpViewController *helpController=[HelpViewController new];
	
	CGRect helpButtonFrame=helpButton.bounds;
	CGRect translatedHelpButtonFrame=[self.view convertRect:helpButtonFrame fromView:helpButton];
	


	self.popController=[[UIPopoverController alloc]
										 initWithContentViewController:helpController];
	self.popController.popoverContentSize=CGSizeMake(600, 600);
	[helpController release];
	popController.delegate=self;
	
	[popController presentPopoverFromRect:translatedHelpButtonFrame
								   inView:self.view
				 permittedArrowDirections:UIPopoverArrowDirectionAny
								 animated:YES];
	
//	[self presentModalViewController:popController animated:YES];
	
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	
	self.popController=nil;
}

-(IBAction) fullScreen:(id) sender {
	[UIView beginAnimations:@"full screen" context:nil];
	CGPoint center=textViewsParent.center;
	CGRect textFrame=textViewsParent.frame;
	CGFloat centerMove=2*center.y-64;
	if (textFrame.origin.y<0)
		centerMove=-(-textFrame.origin.y); // 43 is height of top menu bar
	center.y=center.y-centerMove;
	textViewsParent.center=center;
	CGRect turtleView=outputView.frame;
	turtleView.origin.y-=centerMove;
	turtleView.size.height+=centerMove;
	outputView.frame=turtleView;
	[outputView setNeedsDisplay];
	[UIView commitAnimations];
	fullScreen=!fullScreen;
	
}

-(IBAction) toggleErrorScreen:(id) sender {
	[UIView beginAnimations:@"toggle error screen" context:nil];
	CGPoint errorCenter=debugParentView.center;
	CGRect errorFrame=debugParentView.frame;
	CGRect inputFrame=inputView.frame;
	CGFloat offset=0;
	if (!errorWindowCollapsed) {
		offset=errorFrame.size.width+10;
	} else {
		offset=-errorFrame.size.width-10;
		
	}
	errorCenter.x+=offset;
	inputFrame.size.width+=offset;
	errorWindowCollapsed=!errorWindowCollapsed;
	if (errorWindowCollapsed==TRUE)
		debugParentView.alpha=0;
	else {
		debugParentView.alpha=1.0;
	}


	debugParentView.center=errorCenter;
	inputView.frame=inputFrame;
	[UIView commitAnimations];
}


-(IBAction) doIt:(id) sender {
	
	
    [self.parser setListing:self.inputView.text];
	[self.parser doCommand];
	[self.parser doCommand];
	[self.parser doCommand];
	
	[self.outputView setNeedsDisplay];
	
}
//***********************************************************/
// timerStop - Stops the timer
//
- (void)timerStop
{
	if(timer)
	{
		[UIView beginAnimations:@"startOn" context:nil];
		stopButton.alpha=0.0;
		startButton.alpha=1.0;
		[UIView commitAnimations];
		[timer invalidate];
		[timer release];
		timer = NULL;
	}
}


//***********************************************************/
// timerStart - Starts the timer
//
- (void)timerStart
{
	// First stop the timer if it has already been started, so we can start over from scratch
	if(timer)
	{
		[self timerStop];
	}
	
	// Now create the timer.
	timer = [NSTimer scheduledTimerWithTimeInterval:frequency target:self selector:@selector(timerTask:) userInfo:NULL repeats:YES];
	[timer retain];
}


//***********************************************************/
// timerTask - Details what to do each timer interval
//
- (void)timerTask:(NSTimer *)aTimer
{
	long		stat;
	long		count;
	BOOL		refresh;
	
	count = 6;					// we're cheating here. :)
	refresh = NO;				// per default, don't refresh!
	while(count--)
	{
		stat = [parser doCommand];
		if(kParserUpdateDisplay == stat)
		{
			refresh = YES;
		}
		else if(kParserStop == stat)
		{
			refresh = YES;
			[self timerStop];
			break;
		}
	}
	
	if(refresh)
	{
		[outputView setNeedsDisplay];
	}
	
#if 0
	switch([parser doCommand])
	{
		case kParserStop:			// stop interpreting the program
			[self timerStop];
			// FallThru...
		case kParserUpdateDisplay:		// not all commands update the display; eg. pen up or if the pen is up and the turtle is moving...
			[outputView setNeedsDisplay:YES];
			// FallThru...
		case kParserContinue:			// don't need to do anything
			break;
	}
#endif
}

//***********************************************************/
// run - Starts the timer, and hence the turtle's drawing
//
- (void)run
{
	stopButton.alpha=1.0;
	startButton.alpha=0.0;
	self.parser=[[LogoParser alloc]initWithOutputView:outputView errorView:debugView]; // nil error view
	outputView.parser=self.parser; // set up the parser
	[self timerStop];				// stop processing commands, so that variables are not changed after re-initializing them
#if (defined(DEBUGFLAG) && DEBUGFLAG)
	//	DUMP_OBCOUNT();
#endif
	[parser reset];					// re-initialize variables
	[parser setListing:self.inputView.text];
	[self timerStart];				// start processing
}


//***********************************************************/
// stop - Stops the timer, and hence the turtle's drawing
//
- (void)stop
{
	NSLog(@"stop");
	[self timerStop];	// stop processing commands
#if (defined(DEBUGFLAG) && DEBUGFLAG)
	//	[parser forgetAll];	// clear memory used by parser (for debugging only, as the user should be able to print the output, AND if we need to redraw, we won't have the drawing commands, if we use forgetAll!)
	//	DUMP_OBCOUNT();
#endif
}


// Action method
- (IBAction)run:(id)sender
{
	[UIView beginAnimations:@"startAnimation" context:nil];
	[self run];
	[UIView commitAnimations];
	[self.inputView resignFirstResponder];
	if (!errorWindowCollapsed)
		[self toggleErrorScreen:nil];

}

// Action method
- (IBAction)stop:(id)sender
{
	[UIView beginAnimations:@"stopAnimation" context:nil];
	[self stop];
	[UIView commitAnimations];
}




/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	

	self.frequency=7e-7;

	self.inputView.font=[UIFont fontWithName:@"Courier-Bold" size:16.0];
	NSLog(@"font family names=%@",[UIFont fontNamesForFamilyName:@"courier"]);
	self.debugView.font=[UIFont fontWithName:@"courier" size:14.0];

	[[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(errorTextChanged:)
												name:@"ERROR_TEXT"
											  object:nil];
	[self toggleErrorScreen:nil]; // start with it off
	
	stopButton.alpha=0.0;
	startButton.alpha=1.0;
	
}

-(void) errorTextChanged:(NSNotification*)not {
	if (fullScreen)
		[self fullScreen:nil]; // turn off full screen
	if (errorWindowCollapsed) {
		[self toggleErrorScreen:nil];
		[inputView becomeFirstResponder];// make it first responder
		// totally ghetto for now
		NSRange lineRange=[debugView.text rangeOfString:@"line"];
		if (lineRange.location!=NSNotFound) {
			NSString *lineNumberString=[debugView.text substringFromIndex:lineRange.location+lineRange.length];
			NSInteger lineNumber=[lineNumberString intValue];
			NSInteger index=0;
			NSInteger numberReturns=0;
			NSString *sourceString=inputView.text;
			while (index < [sourceString length] && numberReturns<lineNumber-1) {
				unichar returnKey='\n';
				if ([sourceString characterAtIndex:index]==returnKey)
					numberReturns++;
				index++;
			}
			inputView.selectedRange=NSMakeRange(index, 0);
			[inputView scrollRangeToVisible:NSMakeRange(index,0)];
		}
	
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
	[self.popController dismissPopoverAnimated:NO];
	self.popController=nil;
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self.outputView setNeedsDisplay];
	
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
	self.startButton=nil;
	self.stopButton=nil;
	self.outputView=nil;
	self.parser=nil;
	self.debugView=nil;
	self.inputView=nil;
	self.debugParentView=nil;
	self.textViewsParent=nil;
	self.popController=nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
