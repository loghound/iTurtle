//
//  LogoParser.m
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

#import "LogoParser.h"
#pragma mark FIXME
//#import "NSTextViewOutputExtensions.h"
#import "Turtle.h"
#import "TurtleView.h"
#import "Expression.h"
#import "StackObject.h"
#import "LogoParserExpression.h"
#import "Variable.h"
//#import "LogoStringExtensions.h"
#import "Preferences.h"
#import "LogoColorTable.h"

#include "Commands.h"

@implementation LogoParser

- (void)forgetAll
{
	[self setListing:NULL];		// also clears programCounter and empties stack
	[variables removeAllObjects];
	[turtles removeAllObjects];
	[listeningTurtles removeAllObjects];
}

- (void)reset
{
	Turtle	*turtle;

	[self forgetAll];

	// Clear the drawing area (TurtleView, subclass of NSView)
	[outputView clear];

	// Clear the Error TextView
	[errorView clearAllText];

	// Create the turtle
	turtle = [[Turtle alloc] init];

	// Tell the turtle where he needs to draw and spit out command errors
	[turtle setOutputView:[self outputView]];
	[turtle setErrorView:[self errorView]];

	// Add the turtle to list of available turtles:
	[self addTurtle:turtle];

	// Activate it, so it's ready to use:
	[self activateTurtle:turtle];

	// Release it, we don't own it anymore; the turtle list and the active list now own it:
	[turtle release];
}

- (void)setup
{
		listing = NULL;
		programCounter = NULL;
		stackIndex = 0;
		stack = [[NSMutableArray array] retain];
		variables = [[NSMutableArray array] retain];
		turtles = [[NSMutableArray array] retain];
		listeningTurtles = [[NSMutableArray array] retain];
		outputView = NULL;
		errorView = NULL;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		[self setup];
		[self reset];
	}
	return(self);
}

- (id)initWithOutputView:(id)aOutputView errorView:(id)aErrorView
{
	self = [super init];
	if(self)
	{
		[self setup];
		[self setOutputView:aOutputView];
		[self setErrorView:aErrorView];
		[self reset];
	}
	return(self);
}

- (void)dealloc
{
	[self forgetAll];			// deallocate objects contained in arrays

	[self setListing:NULL];		// also clears programCounter and empties stack
	[stack release];
	stack = NULL;
	[variables release];
	variables = NULL;
	[turtles release];
	turtles = NULL;
	[listeningTurtles release];
	turtles = NULL;
	[self setOutputView:NULL];
	[self setErrorView:NULL];
	[super dealloc];
}

- (void)addTurtle:(Turtle *)aTurtle
{
	[turtles addObject:aTurtle];
}

- (void)removeTurtle:(Turtle *)aTurtle
{
	[turtles removeObject:aTurtle];
}

- (void)activateTurtle:(Turtle *)aTurtle
{
	[listeningTurtles addObject:aTurtle];
// speech-bubbles:
// "Bob here!"
// "Yes?"
// "I'll be there in a minute..."
// "I still feel sleepy!"
// "Couldn't you pick someone else?"
// "I'm Frank, and I'm eager to go!"
}

- (void)deactivateTurtle:(Turtle *)aTurtle
{
	[listeningTurtles removeObject:aTurtle];
}

- (void)deactivateAllTurtles
{
	[listeningTurtles removeAllObjects];
}

- (NSArray *)turtles		// invoked by LogoDocument's drawRect method
{
	return(turtles);
}

- (void)setOutputView:(id)aOutputView
{
	[aOutputView retain];
	[outputView release];
	outputView = aOutputView;
}

- outputView
{
	return(outputView);
}

- (void)setErrorView:(id)aErrorView
{
	[aErrorView retain];
	[errorView release];
	errorView = aErrorView;
}

- errorView
{
	return(errorView);
}

- (void)getCurrentLine:(unsigned long *)p_line andColumn:(unsigned long *)p_column
{
	unsigned long			lineCount;
	unsigned long			column;
	register const unichar	*s;
	register unichar		c;
	unsigned long			l;

	column = 1;
	lineCount = 1;
	s = listing;
	l = programCounter - s;

	while(l--)
	{
		c = *s++;
		if(10 == c && 13 == s[0])			// incorrect line ending style (LF/CR)
		{
			column = 1;
			lineCount++;
			s++;
		}
		else if(13 == c && 10 == s[0])		// DOS style line endings (CR/LF)
		{
			column = 1;
			lineCount++;
			s++;
		}
		else if(10 == c || 13 == c)			// Unix, Linux (LF) or Mac OS (CR) style line endings
		{
			column = 1;
			lineCount++;
		}
		else
		{
			column++;
		}
	}
	if(p_line)
	{
		*p_line = lineCount;
	}
	if(p_column)
	{
		*p_column = column;
	}
}

- (unsigned long)currentLine
{
	unsigned long	lineCount;

	[self getCurrentLine:&lineCount andColumn:NULL];
	return(lineCount);
}

- (void)errorMessage:(NSString *)aMessage
{
	[errorView appendLine:[NSString stringWithFormat:@"Error in line %d:\n%@", [self currentLine], aMessage] ofColor:[UIColor redColor]];
}

- (void)setListing:(NSString *)aListing
{
	unichar			*buffer;
	unsigned long	length;

	if(listing)
	{
		free((void *) listing);
		listing = NULL;
	}
	[stack removeAllObjects];
	stackIndex = 0;
	programCounter = NULL;
	if(aListing)
	{
		length = [aListing length];
		buffer = (unichar *) malloc(sizeof(unichar) * (length + 1));
		if(buffer)
		{
			[aListing getCharacters:buffer];
			buffer[length] = 0;
			listing = buffer;
			programCounter = buffer;
		}
	}
}

- (void)pushProgramCounter:(const unichar *)aProgramCounter withRepeat:(unsigned long)aRepeatCount
{
	StackObject	*obj;

	obj = [[StackObject alloc] initWithProgramCounter:aProgramCounter andRepeat:aRepeatCount];
	[stack addObject:obj];
}

- (void)pop
{
	StackObject	*obj;

	if([stack count])
	{
		obj = [stack lastObject];
		if(obj)
		{
			if([obj count])
			{
				programCounter = [obj programCounter];
				[obj decCount];
			}
			else
			{
				[stack removeLastObject];
			}
		}
	}
}

- (BOOL)getChar:(unichar *)p_char	// get next character and update character position
{
	register unichar	c;

	c = *programCounter;
	if(c)
	{
		programCounter++;
		if(p_char)
		{
			*p_char = c;
		}
		return(YES);
	}
	return(NO);
}

- (unsigned long)skipWhiteIn:(const unichar **)p_aBuffer length:(unsigned long)aLength			// skip over spaces, tabs, linefeeds, formfeeds and carriage returns
{
	register unichar		c;
	register const unichar	*s;
	unsigned long			length;

	length = 0;
	if(p_aBuffer)
	{
		s = *p_aBuffer;
		while(aLength--)
		{
			c = *s;
			if(32 != c && (9 > c || 13 < c))
			{
				break;
			}
			s++;
		}
		length = s - *p_aBuffer;
		*p_aBuffer = s;
	}
	return(length);
}

- (unsigned long)getListElementSize:(const unichar *)aList length:(unsigned long)aListLength
{
	register const unichar	*s;
	register unichar		c;
	unsigned long			length;

	s = aList;
	length = 0;
	c = *s++;
	while(aListLength-- && c && (32 != c && (9 > c || 13 < c)))
	{
		c = *s++;
	}
	length = (s - 1) - aList;
	return(length);
}

- (void)skipWhite			// skip over spaces, tabs, linefeeds, formfeeds and carriage returns
{
	register unichar		c;
	register const unichar	*s;

	s = programCounter;
	c = *s++;
	while(32 == c || (9 <= c && 13 >= c))
	{
		c = *s++;
	}
	s--;
	programCounter = s;
}

#if 0	// a test-thing!
- (const unichar *)firstWhiteOf:(const unichar *)programPtr
{
	register const unichar	*l;
	register const unichar	*s;
	register unichar		c;

	l = listing;
	s = programPtr;
	if(s > l)
	{
		c = ' ';
		while(s > l && (' ' == c || (9 <= c && 13 >= c)))
		{
			c = *--s;
		}
		return(s + 1);
	}
	return(s);
}
#endif

// New doCommand should be able to 'visit' self; eg. not invoke, but using the stack,
// it should push 'return-values', so that commands would place their
// result-of-execution on the stack.
// This will enable us to implement functions like 'color' and 'colorunder',
// that will pass their results back to other commands/functions.

//- (long)dispatchCommand:(long)command withTemplate:(const unsigned char *)aMatchTemplate
- (long)doCommand
{
	long				result;
	BOOL				refresh;
	const unichar		*s;
	Expression			*expression[8];		// currently max 8 expressions are supported. (Only 2 or 3 is actually used). Can be extended if needed!
	unsigned long		count;
	double				condition;
	unsigned long		i;
	unsigned long		expressions;
	const char			*expressionTypes;
	char				t;
	unichar				c;
	BOOL				success;
	NSString			*type;
	Turtle				*turtle;
	const unichar		*unitemp;
	unsigned long		length;
	unsigned long		l;
	NSString			*temp;
	NSString			*name;
	Variable			*variable;
	BOOL				found;
	long				cmd;
	const unichar		*command;
	const unsigned char	*matchTemplate;
	unsigned long		startingLine;
	unsigned long		startingColumn;
	unsigned long		endingLine;
	unsigned long		endingColumn;
#if 0	// a test-thing!
	unsigned long		selectionStart;
	unsigned long		selectionEnd;
#endif

	result = kParserStop;
	// Assume we won't refresh...
	refresh = NO;

	[self skipWhite];
//DEBUGMSG("line:%d\n", [self currentLine]);
#if 0
	selectionStart = programCounter - listing;
	selectionEnd = selectionStart;
#endif
	[self getCurrentLine:&startingLine andColumn:&startingColumn];
	c = *programCounter;
	if(']' == c)
	{
		programCounter++;
		[self pop];
		result = kParserContinue;
	}
	else if('[' == c)
	{
		programCounter++;
//		selectionEnd = programCounter - listing;
		[self pushProgramCounter:programCounter withRepeat:0];
		result = kParserContinue;
	}
	else if('#' == c || ';' == c)		// the rest of the line is a comment
	{
		s = programCounter + 1;
		c = *s++;
		while(c && 10 != c && 13 != c)	// until we meet the end of the line
		{
			c = *s++;
		}
		if(!c)							// zero-termination (end-of-buffer) ?
		{
			s--;						// step back, so we'll always stay inside the buffer
		}
		programCounter = s;				// now point to the next interesting character
//		selectionEnd = programCounter - listing;
		result = kParserContinue;
	}
	else if([self getWord:&command andLength:&length])
	{
		cmd = LookupCommand(command, length, &matchTemplate);
//		selectionEnd = programCounter - listing;
		if(kCommandUnknown == cmd)
		{
			unitemp = programCounter;
			programCounter = command;	// set programCounter to point to the command, so that the correct line/column will be reported!
			[self errorMessage:[NSString stringWithFormat:@"I don't know how to %@", [NSString stringWithCharacters:command length:length]]];
			programCounter = unitemp;
			result = kParserStop;
		}
		else
		{
			expressionTypes = matchTemplate;
			// Check if expressions match the expression template for the command
			expressions = 0;
			success = YES;
			t = *expressionTypes++;
			while(success && t)
			{
				expression[expressions] = [[Expression alloc] init];
				c = programCounter[0];
				if('#' == c)
				{
					s = programCounter + 1;
					c = *s++;
					while(c && 10 != c && 13 != c)
					{
						c = *s++;
					}
					programCounter = s;
				}
				success = [self getExpression:expression[expressions]];
				switch(t)
				{
				  case kExpressionTypeNumber:
					type = @"Nummeric expression";
					success = success ? 0 != (kExpressionKindNumber & [expression[expressions] type]) : NO;
					break;
				  case kExpressionTypeString:		// Note: Numbers *ARE* allowed, because numbers are names (strings) too! -A string is expected, though. ;)
					type = @"String expression";
					success = success ? 0 != ((kExpressionKindNumber & [expression[expressions] type]) || (kExpressionKindStringValue == [expression[expressions] type])) : NO;
					break;
				  case kExpressionTypeNumberOrString:
					type = @"Nummeric or string expression";
					success = success ? 0 != ((kExpressionKindNumber & [expression[expressions] type]) || (kExpressionKindStringValue == [expression[expressions] type])) : NO;
					break;
				  case kExpressionTypeNumberOrList:
					type = @"Number or list expression";
					success = success ? 0 != ((kExpressionKindNumber & [expression[expressions] type]) || (kExpressionKindListValue == [expression[expressions] type])) : NO;
					break;
				  case kExpressionTypeStringOrList:
					type = @"String or list expression";
					success = success ? 0 != ((kExpressionKindNumber & [expression[expressions] type]) || (kExpressionKindStringValue == [expression[expressions] type]) || (kExpressionKindListValue == [expression[expressions] type])) : NO;
					break;
				  case kExpressionTypeNumberOrStringOrList:
					type = @"Number or string or list expression";
					success = success ? 0 != ((kExpressionKindNumber & [expression[expressions] type]) || (kExpressionKindStringValue == [expression[expressions] type]) || (kExpressionKindListValue == [expression[expressions] type])) : NO;
					break;
				  case kExpressionTypeList:
					type = @"List expression";
					success = success ? 0 != (kExpressionKindListValue == [expression[expressions] type]) : NO;
					break;
				  case kExpressionTypeAny:
					type = @"Expression";
					// 'success' remains unchanged, as we allow anything!
					break;
				  default:
					type = @"[Internal error] :) I guess, that an expression is not";
					break;
				}
				if(success)
				{
					expressions++;
				}
				else
				{
					[self errorMessage:[NSString stringWithFormat:@"%@: %@ expected (arg %d)", [NSString stringWithCharacters:command length:length], type, 1 + expressions]];
#if 0
DEBUGMSG("expression[0] type:%08x\n", [expression[0] type]);
if(expressions)
{
DEBUGMSG("expression[1] type:%08x\n", [expression[1] type]);
}
#endif
				}
				t = *expressionTypes++;
			}

			if(success)
			{
//				selectionEnd = programCounter - listing;
				switch(cmd)
				{
					// Commands that are not repeated for each turtle...
				  case kCommandClearGraphics:
					refresh |= [outputView clear];
					break;
				  case kCommandSetBackground:
					if(kExpressionKindNumber & [expression[0] type])
					{
						refresh |= [outputView setPaperColor:[expression[0] floatValue]];
					}
					else
					{
						refresh |= [outputView setPaperColor:[LogoColorTable indexByName:[NSString stringWithCharacters:[expression[0] stringValue] length:[expression[0] length]]]];
					}
					break;

					// Commands that take a list/string only or a list/string plus another parameter.
				  case kCommandTalkTo:			// string or list
					[self deactivateAllTurtles];
				  case kCommandNewTurtle:		// string or list
				  case kCommandRemoveTurtle:	// string or list
				  case kCommandMake:			// string or list and any parameter.
					if(kExpressionKindListValue == [expression[0] type])
					{
						unitemp = [expression[0] listValue];
					}
					else
					{
						unitemp = [expression[0] stringValue];
					}
					l = [expression[0] length];
					while(l)
					{
						length = [self getListElementSize:unitemp length:l];
						if(length)
						{
							temp = [NSString stringWithCharacters:unitemp length:length];
							if(kCommandMake == cmd)
							{
								count = [variables count];
								i = 0;
								while(i < count)	/* sensitive code, please be aware of this. */
								{
									variable = [variables objectAtIndex:i];
									name = [variable name];
									if(NSOrderedSame == [temp caseInsensitiveCompare:name])
									{
										[variables removeObject:variable];
										count--;	/* this is the dirty part, note that i must stay the same! */
									}
									else
									{
										i++;
									}
								}
								[variables addObject:[[Variable alloc] initWithName:temp andExpression:expression[1]]];
							}
							else
							{
								found = NO;
								count = [turtles count];
								for(i = 0; i < count; i++)
								{
									turtle = [turtles objectAtIndex:i];
									if([[turtle turtleName] isEqualToString:temp])
									{
										switch(cmd)
										{
										  case kCommandRemoveTurtle:
											[self deactivateTurtle:turtle];
											[self removeTurtle:turtle];
											break;
										  case kCommandTalkTo:
											[self activateTurtle:turtle];
											break;
										}
										found = YES;
									}
								}
								switch(cmd)
								{
								  case kCommandTalkTo:
								  case kCommandRemoveTurtle:
									if(!found)
									{
										[self errorMessage:[NSString stringWithFormat:@"%@ does not exist", temp]];
									}
									break;
								  case kCommandNewTurtle:
									if(found)
									{
										[self errorMessage:[NSString stringWithFormat:@"Already got a turtle named %@!", temp]];
									}
									else
									{
										if(count < [[Preferences sharedInstance] maxTurtles])
										{
											turtle = [[Turtle alloc] initWithName:temp andColor:[LogoColorTable indexByName:@"brown"]];
											[turtle setOutputView:[self outputView]];
											[turtle setErrorView:[self errorView]];
											[self addTurtle:turtle];
										}
										else
										{
											[self errorMessage:[NSString stringWithFormat:@"Maximum number of turtles reached, cannot create %@", temp]];
										}
									}
									break;
								}
							}
							l -= length;
							unitemp += length;
							l -= [self skipWhiteIn:&unitemp length:l];
						}
					}
					break;
				  case kCommandIf:
					condition = [expression[0] floatValue];
					if(condition)
					{
						if(kExpressionKindListValue == [expression[1] type])
						{
							unitemp = [expression[1] listValue];
							length = [expression[1] length];
							[self pushProgramCounter:unitemp withRepeat:1];
							[self pop];
						}
						else
						{
							[self errorMessage:[NSString stringWithFormat:@"If - list expected!"]];
							// stop parser!
						}
					}
					break;
				  case kCommandIfElse:
					[self errorMessage:[NSString stringWithFormat:@"IfElse - sorry, this command is not yet supported. Will be soon, though. Please use 2 IFs instead for now..."]];
#if 0	// I think it's better that I migrate to the new parser, before continuing the IfElse work!
					condition = [expression[0] floatValue];
					if(condition)
					{
						if(kExpressionKindListValue == [expression[1] type])
						{
							if(kExpressionKindListValue == [expression[2] type])
							{
								if(condition)
								{
									unitemp = [expression[2] listValue];
									length = [expression[2] length];
									[self pushProgramCounter:unitemp withRepeat:0];	// don't execute expression2
									// uhm, this approach won't work!
									unitemp = [expression[1] listValue];
									length = [expression[1] length];
									[self pushProgramCounter:unitemp withRepeat:1];
								}
								else
								{
									unitemp = [expression[2] listValue];
									length = [expression[2] length];
									[self pushProgramCounter:unitemp withRepeat:1];
								}
								[self pop];

#if 0
								i = condition ? 1 : 2;
								unitemp = [expression[i] listValue];
								length = [expression[i] length];
								[self pushProgramCounter:programCounter withRepeat:1];
								[self pushProgramCounter:unitemp withRepeat:1];
								[self pop];
#endif
							}
							else
							{
								[self errorMessage:[NSString stringWithFormat:@"IfElse - list expected (argument 3)!"]];
								// stop parser!
							}
						}
						else
						{
							[self errorMessage:[NSString stringWithFormat:@"IfElse - list expected (argument 2)!"]];
							// stop parser!
						}
					}
#endif
					break;
				  case kCommandRepeat:
					count = [expression[0] floatValue];
					if(kExpressionKindListValue == [expression[1] type])
					{
						unitemp = [expression[1] listValue];
						length = [expression[1] length];
//[self errorMessage:[NSString stringWithFormat:@"Repeat's list: %@", [NSString stringWithCharacters:unitemp length:length]]];
//perhaps:				selectionEnd = unitemp - listing;
						[self pushProgramCounter:unitemp withRepeat:count];
						[self pop];
					}
					else
					{
						[self errorMessage:[NSString stringWithFormat:@"Repeat - list expected!"]];
						// stop parser!
					}
					break;
				  default:
					// Commands that are repeated for each turtle
					count = [listeningTurtles count];
					for(i = 0; i < count; i++)
					{
						turtle = [listeningTurtles objectAtIndex:i];
						switch(cmd)
						{
							// Commands that takes no parameters:
						  case kCommandPenDown:
							refresh |= [turtle penDown];
							break;
						  case kCommandPenErase:
							refresh |= [turtle penErase];
							break;
						  case kCommandPenUp:
							refresh |= [turtle penUp];
							break;
						  case kCommandHideTurtle:
							refresh |= [turtle hide];
							break;
						  case kCommandShowTurtle:
							refresh |= [turtle show];
							break;
						  case kCommandHome:
							refresh |= [turtle home];
							break;
						  case kCommandNorth:
							refresh |= [turtle north];
							break;
						  case kCommandNorthWest:
							refresh |= [turtle northWest];
							break;
						  case kCommandWest:
							refresh |= [turtle west];
							break;
						  case kCommandSouthWest:
							refresh |= [turtle southWest];
							break;
						  case kCommandSouth:
							refresh |= [turtle south];
							break;
						  case kCommandSouthEast:
							refresh |= [turtle southEast];
							break;
						  case kCommandEast:
							refresh |= [turtle east];
							break;
						  case kCommandNorthEast:
							refresh |= [turtle northEast];
							break;

							// Commands that takes one parameter:
						  case kCommandSetHeading:
							refresh |= [turtle setDirection:[expression[0] floatValue]];
							break;
						  case kCommandForward:
							refresh |= [turtle forward:[expression[0] floatValue]];
							break;
						  case kCommandBack:
							refresh |= [turtle back:[expression[0] floatValue]];
							break;
						  case kCommandLeftTurn:
							refresh |= [turtle turnLeft:[expression[0] floatValue]];
							break;
						  case kCommandRightTurn:
							refresh |= [turtle turnRight:[expression[0] floatValue]];
							break;
						  case kCommandSetColor:
							if(kExpressionKindNumber & [expression[0] type])
							{
								refresh |= [turtle setPenColor:[expression[0] floatValue]];
							}
							else
							{
								refresh |= [turtle setPenColor:[LogoColorTable indexByName:[NSString stringWithCharacters:[expression[0] stringValue] length:[expression[0] length]]]];
							}
							break;
						  case kCommandSetTurtleColor:
							if(kExpressionKindNumber & [expression[0] type])
							{
								refresh |= [turtle setTurtleColor:[expression[0] floatValue]];
							}
							else
							{
								refresh |= [turtle setTurtleColor:[LogoColorTable indexByName:[NSString stringWithCharacters:[expression[0] stringValue] length:[expression[0] length]]]];
							}
							break;
						  case kCommandSetTurtleSize:
							if(kExpressionKindNumber & [expression[0] type])
							{
								refresh |= [turtle setTurtleSize:[expression[0] floatValue]];
							}
							else
							{
								// check if '"normal' or '"default'
//								refresh |= [turtle setTurtleSize:[LogoColorTable indexByName:[NSString stringWithCharacters:[expression[0] stringValue] length:[expression[0] length]]]];
							}
							break;
						  case kCommandSetPenSize:
							refresh |= [turtle setPenSize:[expression[0] floatValue]];
							break;

							// Commands that takes two parameters:
						  case kCommandSetXY:	// may be incorrect. setpos [x y] is supported more often
							refresh |= [turtle setLocation:CGPointMake([expression[0] floatValue], [expression[1] floatValue])];
							break;
						  default:
							DEBUGMSG("Command not implemented: %ld\n", cmd);
							break;
						}
					}
				}
				result = refresh ? kParserUpdateDisplay : kParserContinue;
			}
			while(expressions--)
			{
				[expression[expressions] release];
				expression[expressions] = NULL;
			}
		}
	}
//	selectionEnd = [self firstWhiteOf:selectionEnd + listing] - listing;
//	[editorView setSelectedRange:NSMakeRange(selectionStart, selectionEnd - selectionStart)];

#if 0	// JB-version includes a view that shows the current line... Did this to test if it was a good idea
	[self getCurrentLine:&endingLine andColumn:&endingColumn];
	if(startingLine == endingLine)
	{
		[positionView setStringValue:[NSString stringWithFormat:@"line % 3d:%d-%d", startingLine, startingColumn, endingColumn]];
	}
	else if(1 == startingColumn && 1 == endingColumn)
	{
		[positionView setStringValue:[NSString stringWithFormat:@"line % 3d-%d", startingLine, startingColumn, endingLine, endingColumn]];
	}
	else
	{
		[positionView setStringValue:[NSString stringWithFormat:@"line % 3d:%d-%d:%d", startingLine, startingColumn, endingLine, endingColumn]];
	}
#endif
	return(result);
}

@end
