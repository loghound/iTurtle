//
//  Turtle.m
//  Software: XLogo
//
//  Created by Jens Bauer & Jeff Skrysak on Thu Jun 26 2003.
//
//  Copyright (c) 2003 Jens Bauer & Jeff Skrysak
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//  1. Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in the
//     documentation and/or other materials provided with the distribution.
//
//   THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
//   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//   ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
//   FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
//   OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
//   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
//   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
//   OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
//   SUCH DAMAGE.
//

#import "Turtle.h"
#import "DrawCommand.h"
#import "TurtleView.h"
#import "LogoColorTable.h"
#import "Preferences.h"
#include "Utilities.h"

const float	defaultTurtleShape[] = {
	0, 9.8,						// starting distance from drawing point
	90, 0.49,
	45, 2,
	45, 3,
	-45, 4,
	-105, 2,
	0, -2,
	150, 5,
	-25, 2,
	0, -2,
	70, 3,
	45, 5,
	45, 3,
	-105, 2,
	0, -2,
	150, 5,
	-25, 2,
	0, -2,
	70, 4,
	-45, 3,
	45, 2,
	360.0
};


@implementation Turtle


//***********************************************/
// init - Create the new turtle
//
- (id)init
{
	return([self initWithName:@"Bob" andColor:[LogoColorTable indexByName:@"green"]]);
}


//***********************************************/
// initWithName - Create a new, named, turtle
//
- (id)initWithName:(NSString *)aName andColor:(float)aColor
{
	// Create the object data
	self = [super init];

	// If the creation was successful, then continue with the rest...
	if(self)
	{
		path = NULL;
		[self setTurtleName:aName];
		[self setTurtleColor:aColor];
		[self setTurtleSize:1.0];
		[self setTurtleShape:defaultTurtleShape];
		[self setPenColor:[LogoColorTable indexByName:@"black"]];
		[self setPenSize:[[Preferences sharedInstance] lineWidth]];
		[self home];			//
		[self north];			// Put him at (0,0), face him north, show him, and put the pen down
// implement this:
//		if([[Preferences sharedInstance] showTurtleUponCreation])
//		{
			[self show];			// We're not supposed to show the turte!
//		}
		[self penDown];			//
	}

	// Send the new turtle back to the caller (probably to place it into an array)
	return(self);
}


//***********************************************/
// dealloc - Destroy the turtle object
//
- (void)dealloc
{
	[self setOutputView:NULL];
	[self setErrorView:NULL];
	[self setTurtleName:NULL];
	[super dealloc];
}


//***********************************************/
// setTurtleName - Give the turtle a name
//
- (void)setTurtleName:(NSString *)aName
{
	if(turtleName)
	{
		[turtleName release];
	}
	turtleName = [aName retain];
}


// Accessor method
- (NSString *)turtleName
{
	return(turtleName);
}


//***********************************************/
// setTurtleColor - Give the turtle a color
//
- (BOOL)setTurtleColor:(float)aColor
{
	if(aColor != turtleColor)
	{
		turtleColor = aColor;
		return(visible);
	}
	return(NO);
}


// Accessor method
- (float)turtleColor
{
	return(turtleColor);
}


//***********************************************/
// setTurtleSize - Give the turtle a size (1.0 is normal)
//
- (BOOL)setTurtleSize:(float)aTurtleSize
{
	if(aTurtleSize != turtleSize)
	{
		turtleSize = aTurtleSize;
		return(visible);
	}
	return(NO);
}


// Accessor method
- (float)turtleSize
{
	return(turtleSize);
}


//***********************************************/
// setTurtleShape - Give the turtle a shape
//
- (void)setTurtleShape:(const float *)aShape
{
	turtleShape = aShape;
}


//***********************************************/
// setOutputView - Tell the turtle where to draw
//
- (void)setOutputView:(id)aOutputView
{
	[aOutputView retain];
	[outputView release];
	outputView = aOutputView;
}


// Accessor method
- outputView
{
	return(outputView);
}


//*****************************************************/
// setErrorView - Tell the turtle where to list errors
//
- (void)setErrorView:(id)aErrorView
{
	[aErrorView retain];
	[errorView release];
	errorView = aErrorView;
}


// Accessor method
- errorView
{
	return(errorView);
}


//*****************************************************/
// setLocation - Puts the turtle somewhere (x,y)
//
- (BOOL)setLocation:(CGPoint)aLocation
{
	CGPoint	oldLocation;   // CGPoint is a struct of two values, x and y.

	oldLocation = location;
	location = aLocation;

	// If the new location is equal to the old, return FALSE
	return(oldLocation.x != location.x && oldLocation.y != oldLocation.y);
}


// Accessor method
- (CGPoint)location
{
	return(location);
}


//*********************************************************/
// setDirection - Tell the turtle which direction to face
//
- (BOOL)setDirection:(float)aDirection
{
	float	oldDirection;

	oldDirection = direction;

	// make direction in range 0...359.999
	direction = my_dmod(aDirection, 360.0);

	// If the new direction is equal to the old, return FALSE (NO)
	return(oldDirection != direction);
}


// Accessor method
- (float)direction
{
	return(direction);
}


//*********************************************************/
// setVisible - Make the turtle visible on the screen
//
- (BOOL)setVisible:(BOOL)aVisible
{
	BOOL	oldVisible;

	oldVisible = visible;
	visible = aVisible;

	// If the new value is equal to the old, return FALSE (NO)
	return(oldVisible != visible);
}


// Accessor method
- (BOOL)visible
{
	return(visible);
}


//*********************************************************/
// setPenColor - Set the drawing color
//
- (BOOL)setPenColor:(float)aPenColor
{
#if 1
	penColor = aPenColor;

	// For now, just return FALSE (v0.3)
	return(NO);		// There is no change on the paper, only the pen color changes.

#else
	// From JB: This is the alternative if you want it:
	// If you want to emulate a real 'robot-turtle', issue a move:0stepsInDirection:0 command, and return the result from this move command
	if(penColor != aPenColor && kPenDown == pen)
	{
		penColor = aPenColor;
		return([self move:0 stepsInDirection:0]);
	}
	return(NO);
#endif
}


// Accessor method
- (float)penColor
{
	return(penColor);
}


//*********************************************************************/
// setPenSize - Set the width of the line in pixels, that the turtle is drawing
// Accessor method.

- (BOOL)setPenSize:(float)aPenSize
{
	penSize = aPenSize;
	return(NO);
}

// Accessor method.

- (float)penSize
{
	return(penSize);
}


//*********************************************************/
// initPath - Intialize the turtle's path
//
- (void)initPath
{
	// Only initialize if the path hasn't been initialized already
	if(!path)
	{
		path = [[[UIBezierPath alloc] init] retain];
		[path setLineWidth:1.0];
		[path setLineCapStyle:kCGLineCapRound];
		[path setLineJoinStyle:kCGLineJoinRound];
		[path setMiterLimit:4.0];
	}
}


//******************************************************************/
// drawTriangleAt - Draw a triangle at the point and heading given
// This method should really be thrown away, and replaced by a turtle-table.
// The only reason I didn't do that, is that I didn't want to spend time calculating
// the positions of the first corner relative to the center of the triangle.
//
- (void)drawTriangleAt:(CGPoint)aPoint heading:(float)aDirection withColor:(UIColor *)aColor
{
	CGPoint		pt[3];
	float		steps;

	// If the path hasn't be initialized, do so now (rare case)
	if(!path)
	{
		[self initPath];
	}

	steps = 10.0 * turtleSize;

	pt[0] = aPoint;
	pt[1] = aPoint;
	pt[2] = aPoint;

	pt[0].x += sin(aDirection * 2.0 * PI / 360.0) * steps;
	pt[0].y += cos(aDirection * 2.0 * PI / 360.0) * steps;

	aDirection += 120.0;
	if(aDirection >= 360.0)
	{
		aDirection -= 360.0;
	}

	pt[1].x += sin(aDirection * 2.0 * PI / 360.0) * steps;
	pt[1].y += cos(aDirection * 2.0 * PI / 360.0) * steps;

	aDirection += 120.0;
	if(aDirection >= 360.0)
	{
		aDirection -= 360.0;
	}

	pt[2].x += sin(aDirection * 2.0 * PI / 360.0) * steps;
	pt[2].y += cos(aDirection * 2.0 * PI / 360.0) * steps;

	// Set the drawing color
	[aColor set];

	// Now we can start the drawing....
	[path moveToPoint:pt[0]];
	[path lineToPoint:pt[1]];
	[path stroke];
	[path removeAllPoints];

	// Side two of the triangle
	[path moveToPoint:pt[1]];
	[path lineToPoint:pt[2]];
	[path stroke];
	[path removeAllPoints];

	// Side three of the triangle
	[path moveToPoint:pt[2]];
	[path lineToPoint:pt[0]];
	[path stroke];
	[path removeAllPoints];
}


//******************************************************************/
// drawSquareAtt - Draw a square at the point and heading given
//
- (void)drawSquareAt:(CGPoint)aPoint heading:(float)aDirection withColor:(UIColor *)aColor length:(float)sideLength
{
} 


//***********************************************/
// drawTurtleAt - Draws the shape of the turtle 
//
- (void)drawTurtleAt:(CGPoint)aPoint heading:(float)aDirection withColor:(UIColor *)aColor
{
	CGPoint		pt0;	// first point
	CGPoint		pt1;	// from
	CGPoint		pt2;	// to
	float		d;
	float		steps;
	float		dir;
	const float	*s;
	BOOL		more;

	s = turtleShape;

	// If the shape is defined, continue...
	if(s)
	{
		// If there is no path defined, make one.
		if(!path)
		{
			[self initPath];
		}

		// Set the turtle's color to the current color, for drawing
		[aColor set];

		d = *s++;
		steps = *s++ * turtleSize;
		dir = my_dmod(aDirection + d, 360.0);
		pt0.x = aPoint.x + sin(dir * 2.0 * PI / 360.0) * steps;
		pt0.y = aPoint.y + cos(dir * 2.0 * PI / 360.0) * steps;

		pt1 = pt0;
		more = YES;
		while(more)
		{
			d = *s++;
			if(d < 360.0)	// direction is always between -360 and +360
			{
				steps = *s++ * turtleSize;
				dir = my_dmod(dir + d, 360.0);
				pt2.x = pt1.x + sin(dir * 2.0 * PI / 360.0) * steps;
				pt2.y = pt1.y + cos(dir * 2.0 * PI / 360.0) * steps;
			}
			else			// if > +360.0, it's an end-marker
			{
				pt2 = pt0;	// set last point = very first point
				more = NO;	// we only draw this closing line, then we exit the loop
			}

			// Draw one line (we only draw the turtle 'frame', we don't fill it)
			[path moveToPoint:pt1];
			[path lineToPoint:pt2];
			[path stroke];
			[path removeAllPoints];

			// Change the starting point to the end of the last side
			pt1 = pt2;
		}
	}
}


//***********************************************/
// drawAtOffset - Offset draw the turtle
//
- (void)drawAtOffset:(CGPoint)aPoint
{
	if([self visible])
	{
		aPoint.x += [self location].x;
		aPoint.y += [self location].y;
		[self drawTurtleAt:aPoint heading:[self direction] withColor:[LogoColorTable color:[self turtleColor]]];
	}
}


//*********************************************************************/
// moveTo - Move the turtle to a new place, drawing the move if needed
//
- (BOOL)moveTo:(CGPoint)aPoint
{
	DrawCommand	*drawCommand;
	CGPoint		fromPt;
	CGPoint		toPt;
	UIColor		*theColor;

	theColor = [LogoColorTable color:[self penColor]];

	// If we are to draw or erase, do so..
	if(kPenUp != pen)
	{
		fromPt = location;
		toPt = aPoint;
		drawCommand = [[DrawCommand alloc] initWithColor:theColor andLineWidth:penSize fromPoint:fromPt toPoint:toPt];
		[outputView addCommand:drawCommand];
		[drawCommand release];			// release when not allocated using a factory method
	}

	if([self setLocation:aPoint])		// if location changed
	{
		if(kPenUp != pen || visible)	// if we're drawing or erasing or the turtle is visible
		{
			return(YES);				// then we need to update the display!
		}
	}
	return(NO);							// nothing changed, don't update display
}


//*********************************************************************/
// move - Move the turtle using steps
//
- (BOOL)move:(float)aSteps stepsInDirection:(float)aDirection
{
	CGPoint	pt;

	pt = location;
	pt.x += sin(aDirection * 2 * PI / 360.0) * aSteps;
	pt.y += cos(aDirection * 2 * PI / 360.0) * aSteps;
	return([self moveTo:pt]);
}


//*********************************************************************/
// clearGraphics - Clear the screen
//
- (BOOL)clearGraphics
{
	return([outputView clear]);
}


//*********************************************************************/
// home - Send the turtle home
//
- (BOOL)home
{
	CGPoint	pt;

	pt.x = 0.0;
	pt.y = 0.0;
	return([self moveTo:pt]);
}


//*********************************************************************/
// north - Face the turtle North
//
- (BOOL)north
{
	return([self setDirection:0.0] && visible);
}


//*********************************************************************/
// northEast - Face the turtle NorthEast
//
- (BOOL)northEast
{
	return([self setDirection:45.0] && visible);
}


//*********************************************************************/
// east - Face the turtle East
//
- (BOOL)east
{
	return([self setDirection:90.0] && visible);
}


//*********************************************************************/
// southEast - Face the turtle SouthEast
//
- (BOOL)southEast
{
	return([self setDirection:135.0] && visible);
}


//*********************************************************************/
// south - Face the turtle South
//
- (BOOL)south
{
	return([self setDirection:180.0] && visible);
}


//*********************************************************************/
// southWest - Face the turtle SouthWest
//
- (BOOL)southWest
{
	return([self setDirection:225.0] && visible);
}


//*********************************************************************/
// west - Face the turtle West
//
- (BOOL)west
{
	return([self setDirection:270.0] && visible);
}


//*********************************************************************/
// northWest - Face the turtle NorthWest
//
- (BOOL)northWest
{
	return([self setDirection:315.0] && visible);
}


//*********************************************************************/
// back - Send the turtle walking backwards 
//
- (BOOL)back:(float)aSteps
{
	return([self move:aSteps stepsInDirection:direction + 180.0]);
}


//*********************************************************************/
// forward - Send the turtle walking forwards
//
- (BOOL)forward:(float)aSteps
{
	return([self move:aSteps stepsInDirection:direction]);
}


//*********************************************************************/
// turnLeft - Turn the turtle toward the left
//
- (BOOL)turnLeft:(float)aDegrees
{
	return([self setDirection:direction - aDegrees] && visible);
}


//*********************************************************************/
// turnRight - Turn the turtle toward the right
//
- (BOOL)turnRight:(float)aDegrees
{
	return([self setDirection:direction + aDegrees] && visible);
}


//*********************************************************************/
// penUp - Stop drawing by setting the pen to up (off the page)
//
- (BOOL)penUp
{
	pen = kPenUp;
	return(NO);
}


//*********************************************************************/
// penDown - Start drawing by setting the pen to down (on the page)
//
- (BOOL)penDown
{
	pen = kPenDown;
	return(YES);
}


//*********************************************************************/
// penErase - Start erasing by setting the pen to erase (on the page)
//
- (BOOL)penErase
{
	pen = kPenErase;
	return(YES);
}


//*********************************************************************/
// (not really an) Accessor method
// Hide the turtle. When the turtle visibility changes, the turtle is drawn/removed in the update loop.
- (BOOL)hide
{
	return([self setVisible:NO]);
}


//*********************************************************************/
// (not really an) Accessor method
// Show the turtle. When the turtle visibility changes, the turtle is drawn/removed in the update loop.
- (BOOL)show
{
	return([self setVisible:YES]);
}


//*********************************************************************/
// Accessor method
// JB: I really forgot why I wrote this method. It'll probably be good for nothing!
- (BOOL)repeat:(float)aCount
{
	return(NO);
}

@end
