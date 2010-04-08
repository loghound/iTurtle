    //
//  TurtleViewController.m
//  iturtle
//
//  Created by John McLaughlin on 4/7/10.
//  Copyright 2010 Loghound.com. All rights reserved.
//

#import "TurtleViewController.h"


@implementation TurtleViewController
@synthesize parser,outputView;
@synthesize debugView,inputView;
@synthesize frequency;
@synthesize debugParentView,textViewsParent;

-(IBAction) fullScreen:(id) sender {
	[UIView beginAnimations:@"full screen" context:nil];
	CGPoint center=textViewsParent.center;
	CGFloat centerMove=2*center.y;
	center.y=center.y-centerMove;
	textViewsParent.center=center;
	CGRect turtleView=outputView.frame;
	turtleView.origin.y-=centerMove;
	turtleView.size.height+=centerMove;
	outputView.frame=turtleView;
	//
//	CGPoint turtleCenter=outputView.center;
//	turtleCenter.y=turtleCenter.y-centerMove/2;
//	outputView.center=turtleCenter;
//	turtleView.size.height=turtleView.size.height+centerMove;
//	outputView.bounds=turtleView;
	[outputView setNeedsDisplay];
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
	[self timerStop];	// stop processing commands
#if (defined(DEBUGFLAG) && DEBUGFLAG)
	//	[parser forgetAll];	// clear memory used by parser (for debugging only, as the user should be able to print the output, AND if we need to redraw, we won't have the drawing commands, if we use forgetAll!)
	//	DUMP_OBCOUNT();
#endif
}


// Action method
- (IBAction)run:(id)sender
{
	[self run];
}

// Action method
- (IBAction)stop:(id)sender
{
	[self stop];
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
	
	NSString *defaultText=[[NSBundle mainBundle]pathForResource:@"defaultTurtle" ofType:@"txt"];
	if (defaultText) {
		self.inputView.text=[NSString stringWithContentsOfFile:defaultText];
	} else
		self.inputView.text=@"";
	self.frequency=7e-7;
	
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
