//
//  LogoParserExpression.m
//  Software: XLogo
//
//  Created by Jens Bauer on Mon Jun 30 2003.
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
//
// Message from JB: Personally, I hate this file.
// Unfortunately it's not as simple and clean as my other expression handlers
// This is due to the support for strings and lists.
// Indeed, the expression format of Logo is crap! I wish it'd be more logical!
// I tried shortening the methods, by first figuring out which operator is going to be used;
// this saves *some* space, but it's far from perfect!
// 30/7-2003: Messed with lists and words. Disabled code in level7 and moved list/word handling to level0 (getExpression) instead, this works better, but limits possibilites.

#import "LogoParserExpression.h"
#import "LogoParser.h"
#import "Expression.h"
#import "Variable.h"

#include "Utilities.h"

/*

(value)					parantheses, functions and values
+, -, ~					sign
<<, >>					shift left, shift right (bitshift)
&, |, ^					and, or, xor
*, /, %					multiplication, division, modulation
+, -					addition, subtraction
=, <, >, <=, >=, <>		compare

*/



@implementation LogoParser (LogoParserExpression)

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

- (BOOL)getList:(const unichar **)p_list andLength:(unsigned long *)p_length
{
	BOOL					result;
	register const unichar	*s;
	register unichar		c;
	register unsigned long	l;
	register const unichar	*list;
	unsigned long			length;

	result = NO;
	length = 0;
	l = 0;
	s = programCounter;
	list = s;
	if(s)
	{
		c = *s++;
		while(c)
		{
			if('[' == c)
			{
				l++;
			}
			else if(']' == c)
			{
				if(0 == l)
				{
					length = (s - 1) - programCounter;
					programCounter = s - 1;
					result = YES;
					break;
				}
				l--;
			}
			c = *s++;
		}
	}
	if(p_list)
	{
		*p_list = list;
	}
	if(p_length)
	{
		*p_length = length;
	}
	return(result);
}

- (BOOL)getWord:(const unichar **)p_word andLength:(unsigned long *)p_length
{
	BOOL					result;
	register const unichar	*word;
	register unsigned long	length;
	register const unichar	*s;
	register unichar		c;

	result = NO;
	length = 0;
	word = NULL;

	s = programCounter;
	if(s)
	{
		word = s;
		c = *s++;
		while(('a' <= c && 'z' >= c) || ('A' <= c && 'Z' >= c) || ('0' <= c && '9' >= c) || '_' == c || '.' == c)
		{
			c = *s++;
		}
		s--;
		length = s - word;
		programCounter = s;
		result = length > 0;
	}
	if(p_word)
	{
		*p_word = word;
	}
	if(p_length)
	{
		*p_length = length;
	}
	return(result);
}

//- (BOOL)getNumber:(const unichar **)p_word andLength:(unsigned long *)p_length
- (BOOL)getFloat:(float *)p_float
{
	BOOL	result;
	double	d;

	result = [self getDouble:&d];
	if(p_float)
	{
		*p_float = d;
	}
	return(result);
}

- (BOOL)getDouble:(double *)p_double
{
	BOOL					result;
	register const unichar	*word;
	register unsigned long	length;
	register const unichar	*s;
	register unichar		c;
	register double			value;
	register double			temp;
	register int			sign;

	result = NO;
	length = 0;
	word = NULL;

	value = 0.0;
	s = programCounter;
	if(s)
	{
		sign = 1;
		word = s;
		c = *s++;
		if('-' == c)
		{
			c = *s++;
			sign = -1;
		}
		if('0' <= c && '9' >= c)
		{
			result = YES;					// it's a number alright!
			while('0' <= c && '9' >= c)
			{
				value = (value * 10.0) + ((double) (c - '0'));
				c = *s++;
			}
		}
		if('.' == c)
		{
			c = *s++;
			if('0' <= c && '9' >= c)
			{
				temp = 0.1;
				result = YES;
				while('0' <= c && '9' >= c)
				{
					value += temp * ((double) (c - '0'));
					temp /= 10.0;
					c = *s++;
				}
			}
		}
		s--;								// step back to the character that failed
		if(result)							// if this was really a number...
		{
			length = s - word;				// ...figure out how much we've read...
			programCounter = s;				// ...and update the program counter
		}
	}
#if 0
	if(p_word)
	{
		*p_word = word;
	}
	if(p_length)
	{
		*p_length = length;
	}
#else
	if(p_double)
	{
		*p_double = value;
	}
#endif
	return(result);
}

- (BOOL)level7:(Expression *)expression					// Value
{
	BOOL					result;
	const unichar			*s;
	register unichar		c;
	unsigned long			length;
	double					value;
	NSString				*varName;
	NSString				*funcName;
	NSString				*name;
	unsigned				count;
	unsigned long			i;
	Variable				*variable;

	result = NO;

	[self skipWhite];
	s = programCounter;
	c = *s++;
	switch(c)
	{
	  case '(':		// paranthese
		programCounter = s;
		result = [self level1:expression];
		if(result && ')' == programCounter[0])
		{
			programCounter++;
		}
		else
		{
			result = NO;
			programCounter = s - 1;
		}
		break;
#if 0
	  case '"':		// word
		programCounter = s;
		result = [self getWord:&s andLength:&length];
		if(result)
		{
			[expression setStringValue:s ofLength:length];
		}
		else
		{
			programCounter = s - 1;
		}
		break;
#endif
	  case ':':		// variable
		programCounter = s;
		result = [self getWord:&s andLength:&length];
		if(result)
		{
			varName = [NSString stringWithCharacters:s length:length];
			count = [variables count];
			for(i = 0; i < count; i++)
			{
				variable = [variables objectAtIndex:i];
				name = [variable name];
				if(NSOrderedSame == [varName caseInsensitiveCompare:name])
				{
					switch([[variable expression] type])
					{
					  case kExpressionKindFloatValue:
						[expression setFloatValue:[[variable expression] floatValue]];
						break;
					  case kExpressionKindListValue:
						[expression setListValue:[[variable expression] listValue] ofLength:[[variable expression] length]];
						break;
					  case kExpressionKindStringValue:
						[expression setStringValue:[[variable expression] stringValue] ofLength:[[variable expression] length]];
						break;
					}
					return(YES);
				}
			}
			// Correct the above to...
			// go through array of variables, compare name, if name is the same, grab value and type: expr = ([[[[turtle symbols] objectAtIndex:i] expression] retain]); return(YES);
			// note: a symbol can belong to one specific turtle, a list of turtles, or shared between all turtles.
			// priority: look for symbol in active turtle, if it isn't found, look for symbol in global symbol list.
		}
		else
		{
			programCounter = s - 1;
		}
		break;
#if 0
	  case '[':		// list
		programCounter = s;
		result = [self getList:&s andLength:&length];
		if(result)
		{
			programCounter++;
			[expression setListValue:s ofLength:length];
		}
		else
		{
			programCounter = s - 1;
		}
		break;
#endif
	  default:		// probably a number
		if(('a' <= c && 'z' >= c) || ('A' <= c && 'Z' >= c))	// first char = a-zA-Z ?
		{
			result = [self getWord:&s andLength:&length];
			funcName = [NSString stringWithCharacters:s length:length];
			if(NSOrderedSame == [funcName caseInsensitiveCompare:@"random"])
			{
				value = JBRandom();
				[expression setFloatValue:value];
			}
			else if(NSOrderedSame == [funcName caseInsensitiveCompare:@"seconds"])
			{
				value = FSTime();
				[expression setFloatValue:value];
			}
		}
		else
		{
			result = [self getDouble:&value];
			if(result)
			{
				[expression setFloatValue:value];
			}
		}
	}
	return(result);
}

- (BOOL)level6:(Expression *)expression					// Sign ('+', '-', '~')
{
	BOOL			result;
	const unichar	*s;
	unichar			c;
	long			type;
	long			operator;

	result = NO;

	[self skipWhite];
	s = programCounter;
	c = programCounter[0];								// Get operator character.
	operator = kOperatorNone;
	switch(c)
	{
	  case '+':
		operator = kOperatorPlus;
		programCounter++;
		break;
	  case '-':
		operator = kOperatorNegate;
		programCounter++;
		break;
	  case '~':
		operator = kOperatorInvert;
		programCounter++;
		break;
	  default:
		return([self level7:expression]);				// Return first expression (left hand)
		break;
	}
	if([self level6:expression])						// Get first expression (left hand)
	{
		type = [expression type];						// Get type of this first expression
		if(kExpressionKindNumber & [expression type])
		{
			result = YES;
			s = programCounter;
			switch(operator)
			{
			  case kOperatorPlus:	// do nothing
				break;
			  case kOperatorNegate:	// negate expression
				[expression setFloatValue:-[expression floatValue]];
				break;
			  case kOperatorInvert:	// invert expression (by subtracting it from -1.0)
				[expression setFloatValue:-1.0 - [expression floatValue]];
				break;
			  default:
				DEBUGMSG("Internal error!\n");
				break;
			}
		}
		else
		{
			// can't do sign on a name or list.
		}
	}
	programCounter = s;
	return(result);
}

- (BOOL)level5:(Expression *)expression					// Shift Left, Shift Right (very time consuming, avoid using these if possible!)
{
	BOOL			result;
	Expression		*right;
	const unichar	*s;
	unichar			c;
	long			type;
	long			operator;
	double			val1;
	double			val2;

	result = NO;
	s = programCounter;
	if([self level6:expression])						// Get first expression (left hand)
	{
		type = [expression type];						// Get type of this first expression

		right = [[Expression alloc] init];
		result = YES;
		while(YES == result)
		{
			[self skipWhite];
			s = programCounter;
			c = programCounter[0];						// Get operator character.
			operator = kOperatorNone;
			if(c == programCounter[1])					// We need 2 matching characters, either '<<' or '>>'
			{
				switch(c)
				{
				  case '<':
					operator = kOperatorShiftLeft;
					break;
				  case '>':
					operator = kOperatorShiftRight;
					break;
				}
			}
			if(kOperatorNone == operator)				// If operator isn't recognized...
			{
				break;									// Exit. Note: result is YES, which means success (End of expression). We also point to the failing character.
			}
			programCounter += 2;						// Skip over the 2 matching characters
			result = [self level6:right];				// Read right-hand expression
			if(result)									// OK ?
			{
				result = NO;							// Assume we'll fail
				if(type == [right type])				// Are both expressions of the same type ?
				{
					if(kExpressionKindNumber & type)	// If type is a number, we know how to handle it
					{
						s = programCounter;
						result = YES;					// Everything is alright, this is a success!
						val1 = [expression floatValue];
						val2 = [right floatValue];
						switch(operator)
						{
						  case kOperatorShiftLeft:	// unfortunately, I don't have a my_fshl
							while(val2 >= 1)
							{
								val1 = (val1 * 2);
								val2--;
							}
							break;
						  case kOperatorShiftRight:	// unfortunately, I don't have a my_fshr
							while(val2 >= 1)
							{
								val1 = (val1 / 2);
								val2--;
							}
							break;
						}
						[expression setFloatValue:val1];
					}
				}
			}
		}
		if(right)
		{
			[right release];
			right = NULL;
		}
	}
	programCounter = s;
	return(result);
}

- (BOOL)level4:(Expression *)expression					// And, Or, Xor
{
	BOOL			result;
	Expression		*right;
	const unichar	*s;
	unichar			c;
	long			type;
	long			operator;
	double			val1;
	double			val2;

	result = NO;
	s = programCounter;
	if([self level5:expression])						// Get first expression (left hand)
	{
		type = [expression type];						// Get type of this first expression

		right = [[Expression alloc] init];
		result = YES;
		while(YES == result)
		{
			[self skipWhite];
			s = programCounter;
			c = programCounter[0];						// Get operator character.
			operator = kOperatorNone;
			switch(c)
			{
			  case '&':
				operator = kOperatorAnd;
				break;
			  case '|':
				operator = kOperatorOr;
				break;
			  case '^':
				operator = kOperatorXor;
				break;
			}
			if(kOperatorNone == operator)				// If operator isn't recognized...
			{
				break;									// Exit. Note: result is YES, which means success (End of expression). We also point to the failing character.
			}
			programCounter++;
			result = [self level5:right];				// Read right-hand expression
			if(result)									// OK ?
			{
				result = NO;							// Assume we'll fail
				if(type == [right type])				// Are both expressions of the same type ?
				{
					if(kExpressionKindNumber & type)	// If type is a number, we know how to handle it
					{
						s = programCounter;
						result = YES;					// Everything is alright, this is a success!
						val1 = [expression floatValue];
						val2 = [right floatValue];
						switch(operator)
						{
						  case kOperatorAnd:
							val1 = ((long) val1) & ((long) val2);	// unfortunately, I don't have a my_fand
							break;
						  case kOperatorOr:
							val1 = ((long) val1) | ((long) val2);	// unfortunately, I don't have a my_for
							break;
						  case kOperatorXor:
							val1 = ((long) val1) ^ ((long) val2);	// unfortunately, I don't have a my_fxor
							break;
						}
						[expression setFloatValue:val1];
					}
				}
			}
		}
		if(right)
		{
			[right release];
			right = NULL;
		}
	}
	programCounter = s;
	return(result);
}

- (BOOL)level3:(Expression *)expression					// Multiplication, Division, Modulo
{
	BOOL			result;
	Expression		*right;
	const unichar	*s;
	unichar			c;
	long			type;
	long			operator;
	double			val1;
	double			val2;

	result = NO;
	s = programCounter;
	if([self level4:expression])						// Get first expression (left hand)
	{
		type = [expression type];						// Get type of this first expression

		right = [[Expression alloc] init];
		result = YES;
		while(YES == result)
		{
			[self skipWhite];
			s = programCounter;
			c = programCounter[0];						// Get operator character.
			operator = kOperatorNone;
			switch(c)
			{
			  case '*':
				operator = kOperatorMultiply;
				break;
			  case '/':
				operator = kOperatorDivide;
				break;
			  case '%':
				operator = kOperatorModulo;
				break;
			}
			if(kOperatorNone == operator)				// If operator isn't recognized...
			{
				break;									// Exit. Note: result is YES, which means success (End of expression). We also point to the failing character.
			}
			programCounter++;							// Skip over the operator character
			result = [self level4:right];				// Read right-hand expression
			if(result)									// OK ?
			{
				result = NO;							// Assume we'll fail
				if(type == [right type])				// Are both expressions of the same type ?
				{
					if(kExpressionKindNumber & type)	// If type is a number, we know how to handle it
					{
						s = programCounter;
						result = YES;					// Everything is alright, this is a success!
						val1 = [expression floatValue];
						val2 = [right floatValue];
						switch(operator)
						{
						  case kOperatorMultiply:
							val1 = (val1 * val2);
							break;
						  case kOperatorDivide:
							val1 = (val1 / val2);
							break;
						  case kOperatorModulo:
							val1 = my_dmod(val1, val2);
							break;
						}
						[expression setFloatValue:val1];
					}
				}
			}
		}
		if(right)
		{
			[right release];
			right = NULL;
		}
	}
	programCounter = s;
	return(result);
}

- (BOOL)level2:(Expression *)expression					// Addition, Subtraction
{
	BOOL			result;
	Expression		*right;
	const unichar	*s;
	unichar			c;
	long			type;
	long			operator;
	double			val1;
	double			val2;

	result = NO;
	s = programCounter;
	if([self level3:expression])						// Get first expression (left hand)
	{
		type = [expression type];						// Get type of this first expression

		right = [[Expression alloc] init];
		result = YES;
		while(YES == result)
		{
			[self skipWhite];
			s = programCounter;
			c = programCounter[0];						// Get operator character.
			operator = kOperatorNone;
			switch(c)
			{
			  case '+':
				operator = kOperatorAdd;
				break;
			  case '-':
				operator = kOperatorSubtract;
				break;
			}
			if(kOperatorNone == operator)				// If operator isn't recognized...
			{
				break;									// Exit. Note: result is YES, which means success (End of expression). We also point to the failing character.
			}
			programCounter++;							// Skip over the operator character
			result = [self level3:right];				// Read right-hand expression
			if(result)									// OK ?
			{
				result = NO;							// Assume we'll fail
				if(type == [right type])				// Are both expressions of the same type ?
				{
					if(kExpressionKindNumber & type)	// If type is a number, we know how to handle it
					{
						s = programCounter;
						result = YES;					// Everything is alright, this is a success!
						val1 = [expression floatValue];
						val2 = [right floatValue];
						switch(operator)
						{
						  case kOperatorAdd:
							val1 = (val1 + val2);
							break;
						  case kOperatorSubtract:
							val1 = (val1 - val2);
							break;
						}
						[expression setFloatValue:val1];
					}
				}
			}
		}
		if(right)
		{
			[right release];
			right = NULL;
		}
	}
	programCounter = s;
	return(result);
}

- (BOOL)level1:(Expression *)expression					// Comparing
{
	BOOL			result;
	Expression		*right;
	const unichar	*s;
	unichar			c;
	unichar			c1;
	long			type;
	long			operator;
	double			val1;
	double			val2;

	result = NO;
	s = programCounter;
	if([self level2:expression])						// Get first expression (left hand)
	{
		type = [expression type];						// Get type of this first expression

		right = [[Expression alloc] init];
		result = YES;
		while(YES == result)
		{
			[self skipWhite];
			s = programCounter;
			c = programCounter[0];						// Get operator character.
			operator = kOperatorNone;
			if(c)
			{
				c1 = programCounter[1];					// Get another operator character in case we need it.
			}
			else
			{
				c1 = 0;
			}
			switch((c << 8) | c1)
			{
			  case (('<' << 8) | '='):
			  case (('=' << 8) | '<'):
				operator = kOperatorLessOrEqual;
				programCounter += 2;
				break;
			  case (('>' << 8) | '='):
			  case (('=' << 8) | '>'):
				operator = kOperatorGreaterOrEqual;
				programCounter += 2;
				break;
			  case (('<' << 8) | '>'):
			  case (('>' << 8) | '<'):
			  case (('!' << 8) | '='):
				operator = kOperatorNotEqual;
				programCounter += 2;
				break;
			  default:
				if('=' == c)
				{
					operator = kOperatorEqual;
					programCounter++;
				}
				else if('>' == c)
				{
					operator = kOperatorGreater;
					programCounter++;
				}
				else if('<' == c)
				{
					operator = kOperatorLess;
					programCounter++;
				}
#if 0	// extras... Just because you can, it doesn't mean you should...
				else if('­' == c)
				{
					operator = kOperatorNotEqual;
					programCounter++;
				}
				else if('³' == c)
				{
					operator = kOperatorGreaterOrEqual;
					programCounter++;
				}
				else if('²' == c)
				{
					operator = kOperatorLessOrEqual;
					programCounter++;
				}
#endif
				break;
			}
			if(kOperatorNone == operator)				// If operator isn't recognized...
			{
				break;									// Exit. Note: result is YES, which means success (End of expression). We also point to the failing character.
			}
			result = [self level2:right];				// Read right-hand expression
			if(result)									// OK ?
			{
				result = NO;							// Assume we'll fail
				if(type == [right type])				// Are both expressions of the same type ?
				{
					if(kExpressionKindNumber & type)	// If type is a number, we know how to handle it
					{
						s = programCounter;
						result = YES;					// Everything is alright, this is a success!
						val1 = [expression floatValue];
						val2 = [right floatValue];
						switch(operator)
						{
						  case kOperatorEqual:
							val1 = (val1 == val2);
							break;
						  case kOperatorNotEqual:
							val1 = (val1 != val2);
							break;
						  case kOperatorLess:
							val1 = (val1 < val2);
							break;
						  case kOperatorGreater:
							val1 = (val1 > val2);
							break;
						  case kOperatorLessOrEqual:
							val1 = (val1 <= val2);
							break;
						  case kOperatorGreaterOrEqual:
							val1 = (val1 >= val2);
							break;
						}
						[expression setFloatValue:val1];
					}
				}
			}
		}
		if(right)
		{
			[right release];
			right = NULL;
		}
	}
	programCounter = s;
	return(result);
}

- (BOOL)getExpression:(Expression *)expression
{
	BOOL			result;
	const unichar	*oldPC;
	const unichar	*s;
	unichar			c;
	unsigned long	length;

	oldPC = programCounter;				// save in case of failure

	result = NO;
	[self skipWhite];
	s = programCounter;
	c = *s++;
	switch(c)
	{
	  case '"':		// word (word cannot be operated on!)
		programCounter = s;
		result = [self getWord:&s andLength:&length];
		if(result)
		{
			[expression setStringValue:s ofLength:length];
		}
		else
		{
			programCounter = s - 1;
		}
		break;
	  case '[':		// list (list cannot be operated on!)
		programCounter = s;
		result = [self getList:&s andLength:&length];
		if(result)
		{
			programCounter++;
			[expression setListValue:s ofLength:length];
		}
		else
		{
			programCounter = s - 1;
		}
		break;
	  default:
		result = [self level1:expression];
		break;
	}
	if(NO == result)
	{
		programCounter = oldPC;			// failure, jump back to start!
	}
	return(result);
}

@end
