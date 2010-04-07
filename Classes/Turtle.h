//
//  Turtle.h
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

#include "Debugging.h"

#import <UIKit/UIKit.h>

enum
{
	kPenUp		= 0,
	kPenErase	= 1,
	kPenDown	= 2
};

@interface Turtle : NSObject
{
    IBOutlet id		errorView;
    IBOutlet id		outputView;

	NSString		*turtleName;		// Name of the turtle
	float			turtleColor;		// Color of the turtle
	float			turtleSize;			// Size of the turtle (normally 1.0)
	const float		*turtleShape;		// Shape of the turtle (polygon points)
	UIBezierPath	*path;

	CGPoint			location;			// Location of the turtle
	float			direction;			// Direction they are facing
	float			penColor;			// Drawing color
	float			penSize;			// Size of pen in pixels (lineWidth)
	int				pen;				// Pen up or pen down
	BOOL			visible;			// Show the turtle to the user or not
}

// Creation and destruction
- (id)initWithName:(NSString *)aName andColor:(float)aColor;
- (void)dealloc;

// Accessor methods
- (void)setTurtleName:(NSString *)aName;
- (NSString *)turtleName;
- (void)setTurtleShape:(const float *)aShape;	// { first point direction, first point steps, [direction, steps, ...], 360.0 (end marker) }
- (void)setOutputView:(id)aOutputView;
- outputView;
- (void)setErrorView:(id)aErrorView;
- errorView;

- (BOOL)setTurtleColor:(float)aColor;
- (float)turtleColor;
- (BOOL)setTurtleSize:(float)aTurtleSize;
- (float)turtleSize;
- (BOOL)setLocation:(CGPoint)aLocation;
- (CGPoint)location;
- (BOOL)setDirection:(float)aDirection;
- (float)direction;
- (BOOL)setVisible:(BOOL)aVisible;
- (BOOL)visible;
- (BOOL)setPenColor:(float)aPenColor;
- (float)penColor;
- (BOOL)setPenSize:(float)aPenSize;
- (float)penSize;

// Draw Commands
- (void)drawTriangleAt:(CGPoint)aPoint heading:(float)aDirection withColor:(UIColor *)aColor;
- (void)drawSquareAt:(CGPoint)aPoint heading:(float)aDirection withColor:(UIColor *)aColor length:(float)sideLength;
- (void)drawTurtleAt:(CGPoint)aPoint heading:(float)aDirection withColor:(UIColor *)aColor;
- (void)drawAtOffset:(CGPoint)aPoint;

// Movement commands
- (BOOL)moveTo:(CGPoint)aPoint;
- (BOOL)move:(float)aSteps stepsInDirection:(float)aDirection;
- (BOOL)clearGraphics;
- (BOOL)home;
- (BOOL)north;
- (BOOL)northWest;
- (BOOL)west;
- (BOOL)southWest;
- (BOOL)south;
- (BOOL)southEast;
- (BOOL)east;
- (BOOL)northEast;
- (BOOL)back:(float)aSteps;
- (BOOL)forward:(float)aSteps;
- (BOOL)turnLeft:(float)aDegrees;
- (BOOL)turnRight:(float)aDegrees;
- (BOOL)penUp;
- (BOOL)penErase;
- (BOOL)penDown;
- (BOOL)hide;
- (BOOL)show;

@end
