//
//  LogoParser.h
//  Software: XLogo
//
//  Created by Jens Bauer on Wed Jun 25 2003.
//
//  Copyright (c) 2003 Jens Bauer
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
	kParserStop				= 0,
	kParserContinue,
	kParserUpdateDisplay,
};

enum
{
	kOperatorNone			= 0,
	kOperatorEqual,
	kOperatorNotEqual,
	kOperatorLessOrEqual,
	kOperatorGreaterOrEqual,
	kOperatorLess,
	kOperatorGreater,

	kOperatorAdd,
	kOperatorSubtract,

	kOperatorMultiply,
	kOperatorDivide,
	kOperatorModulo,

	kOperatorAnd,
	kOperatorOr,
	kOperatorXor,

	kOperatorShiftLeft,
	kOperatorShiftRight,

	kOperatorPlus,			// sign
	kOperatorNegate,		// sign
	kOperatorInvert			// sign

};

@class Turtle;
@class Expression;
@interface LogoParser : NSObject
{
	IBOutlet id		outputView;
	IBOutlet id		errorView;

	const unichar	*listing;				// listing
	const unichar	*programCounter;		// current position in listing

	NSMutableArray	*turtles;				// the available turtles (inactive+active)
	NSMutableArray	*listeningTurtles;		// the active turtles

	NSMutableArray	*variables;				// variables (names+expressions)
	NSMutableArray	*stack;					// call-stack (not used yet)
	unsigned		stackIndex;				// current index in call-stack
}

// Creation and destruction
- (id)initWithOutputView:(id)aOutputView errorView:(id)aErrorView;
- (void)dealloc;

- (void)forgetAll;	// forget all recordings, but don't change display
- (void)reset;		// clears display and creates a new turtle

// Turtle management
- (void)addTurtle:(Turtle *)aTurtle;
- (void)removeTurtle:(Turtle *)aTurtle;
- (void)activateTurtle:(Turtle *)aTurtle;
- (void)deactivateTurtle:(Turtle *)aTurtle;
- (void)deactivateAllTurtles;
- (NSArray *)turtles;
- (void)setOutputView:(id)aOutputView;
- outputView;
- (void)setErrorView:(id)aErrorView;
- errorView;
- (void)setListing:(NSString *)aListing;
//- (void)setLines:(NSArray *)aLines;
//- (NSArray *)lines;
- (long)doCommand;
@end
