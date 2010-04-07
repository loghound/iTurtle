//
//  Commands.c
//  Software: XLogo
//
//  Created by Jens Bauer on Fri Jun 27 2003.
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

#include <string.h>		/* for NULL, strlen and strcpy */
#include <stdlib.h>		/* for malloc */

#include "Utilities.h"
#include "Commands.h"

Command	*g_commands = NULL;
long	g_commandCount = 0;

void InitCommands()
{
	typedef struct CommandList CommandList;
	struct CommandList
	{
		const unsigned char	*name;
		long				commandNumber;
		unsigned char		matchTemplate[8];
	};

	static CommandList	commandList[]= {
		{ "bk", kCommandBack, { kExpressionTypeNumber, 0 } },									/* implemented */
		{ "fd", kCommandForward, { kExpressionTypeNumber, 0 } },								/* implemented */
		{ "lt", kCommandLeftTurn, { kExpressionTypeNumber, 0 } },								/* implemented */
		{ "rt", kCommandRightTurn, { kExpressionTypeNumber, 0 } },								/* implemented */
		{ "pd", kCommandPenDown, { 0 } },														/* implemented */
		{ "pe", kCommandPenErase, { 0 } },														/* implemented */
		{ "pu", kCommandPenUp, { 0 } },															/* implemented */
		{ "if", kCommandIf, { kExpressionTypeNumber, kExpressionTypeList, 0 } },				/* implemented */
		{ "n", kCommandNorth, { 0 } },															/* implemented */
		{ "nw", kCommandNorthWest, { 0 } },														/* implemented */
		{ "w", kCommandWest, { 0 } },															/* implemented */
		{ "sw", kCommandSouthWest, { 0 } },														/* implemented */
		{ "s", kCommandSouth, { 0 } },															/* implemented */
		{ "se", kCommandSouthEast, { 0 } },														/* implemented */
		{ "e", kCommandEast, { 0 } },															/* implemented */
		{ "ne", kCommandNorthEast, { 0 } },														/* implemented */
		{ "ht", kCommandHideTurtle, { 0 } },													/* implemented */
		{ "st", kCommandShowTurtle, { 0 } },													/* implemented */
		{ "cg", kCommandClearGraphics, { 0 } },													/* implemented */
		{ "cc", kCommandClearCommands, { 0 } },
		{ "to", kCommandTo, { 0 } },
		{ "tto", kCommandTalkTo, { kExpressionTypeStringOrList, 0 } },							/* implemented */
		{ "end", kCommandEnd, { 0 } },
		{ "ifelse", kCommandIfElse, { kExpressionTypeNumber, kExpressionTypeList, kExpressionTypeList, 0 } },	/* implemented */
		{ "fill", kCommandFloodFill, { 0 } },
		{ "seth", kCommandSetHeading, { kExpressionTypeNumber, 0 } },							/* implemented */
		{ "setc", kCommandSetColor, { kExpressionTypeNumberOrString, 0 } },						/* implemented */
		{ "setbg", kCommandSetBackground, { kExpressionTypeNumberOrString, 0 } },				/* implemented */
		{ "setxy", kCommandSetXY, { kExpressionTypeNumber, kExpressionTypeNumber, 0 } },		/* implemented */
		{ "setpos", kCommandSetPosition, { kExpressionTypeList, 0 } },
		{ "newturtle", kCommandNewTurtle, { kExpressionTypeStringOrList, 0 } },					/* implemented */
		{ "remove", kCommandRemoveTurtle, { kExpressionTypeStringOrList, 0 } },					/* implemented */
		{ "setturtlecolor", kCommandSetTurtleColor, { kExpressionTypeNumberOrString, 0 } },		/* implemented */
		{ "setturtlesize", kCommandSetTurtleSize, { kExpressionTypeNumber, 0 } },				/* implemented */
		{ "repeat", kCommandRepeat, { kExpressionTypeNumber, kExpressionTypeList, 0 } },		/* implemented */
		{ "make", kCommandMake, { kExpressionTypeStringOrList, kExpressionTypeAny, 0 } },		/* implemented */

		{ "back", kCommandBack, { kExpressionTypeNumber, 0 } },									/* implemented */
		{ "forward", kCommandForward, { kExpressionTypeNumber, 0 } },							/* implemented */
		{ "left", kCommandLeftTurn, { kExpressionTypeNumber, 0 } },								/* implemented */
		{ "right", kCommandRightTurn, { kExpressionTypeNumber, 0 } },							/* implemented */
		{ "pendown", kCommandPenDown, { 0 } },													/* implemented */
		{ "penerase", kCommandPenErase, { 0 } },												/* implemented */
		{ "penup", kCommandPenUp, { 0 } },														/* implemented */
		{ "north", kCommandNorth, { 0 } },														/* implemented */
		{ "northwest", kCommandNorthWest, { 0 } },												/* implemented */
		{ "west", kCommandWest, { 0 } },														/* implemented */
		{ "southwest", kCommandSouthWest, { 0 } },												/* implemented */
		{ "south", kCommandSouth, { 0 } },														/* implemented */
		{ "southeast", kCommandSouthEast, { 0 } },												/* implemented */
		{ "east", kCommandEast, { 0 } },														/* implemented */
		{ "northeast", kCommandNorthEast, { 0 } },												/* implemented */
		{ "hideturtle", kCommandHideTurtle, { 0 } },											/* implemented */
		{ "showturtle", kCommandShowTurtle, { 0 } },											/* implemented */
		{ "home", kCommandHome, { 0 } },														/* implemented */
		{ "clear", kCommandClearGraphics, { 0 } },												/* implemented */
		{ "talkto", kCommandTalkTo, { kExpressionTypeStringOrList, 0 } },						/* implemented */
		{ "cleargraphics", kCommandClearGraphics, { 0 } },										/* implemented */
		{ "clearcommands", kCommandClearCommands, { 0 } },
		{ "setheading", kCommandSetHeading, { kExpressionTypeNumber, 0 } },						/* implemented */
		{ "setcolor", kCommandSetColor, { kExpressionTypeNumberOrString, 0 } },					/* implemented */
		{ "setbackground", kCommandSetBackground, { kExpressionTypeNumberOrString, 0 } },		/* implemented */
		{ "floodfill", kCommandFloodFill, { 0 } },
		{ "setposition", kCommandSetPosition, { 0 } },
		{ "removeturtle", kCommandRemoveTurtle, { kExpressionTypeStringOrList, 0 } },			/* implemented */
		{ "setpensize", kCommandSetPenSize, { kExpressionTypeNumber, 0 } },						/* implemented */

		{ NULL, kCommandUnknown }
	};
	int					i;
	int					size;
	const unsigned char	*s;
	unichar				*d;
	unichar				c;

	if(!g_commands)
	{
		size = sizeof(commandList) / sizeof(*commandList);
		g_commands = (Command *) malloc(size * sizeof(*g_commands));
		g_commandCount = size;
		for(i = 0; i < size; i++)
		{
			s = commandList[i].name;
			d = s ? (unichar *) malloc(sizeof(unichar) * (strlen(s) + 1)) : NULL;
			g_commands[i].name = d;
			if(s && d)
			{
				c = *s++;
				while(c)
				{
					*d++ = c;
					c = *s++;
				}
				*d++ = c;
			}
			g_commands[i].commandNumber = commandList[i].commandNumber;
			strcpy((char *) g_commands[i].matchTemplate, (char *) commandList[i].matchTemplate);	// ugly but short. :)
#if 0
			j = 0;
			c = 1;
			while(c)
			{
				c = commandList[i].matchTemplate[j];
				g_commands[i].matchTemplate[j++] = c;
			}
#endif
		}
	}
}

long LookupCommand(const unichar *aCommand, unsigned long length, const unsigned char **p_template)
{
	Command	*p;

	p = g_commands;
	if(!p)
	{
		InitCommands();
		p = g_commands;
	}
	while(p->name)
	{
		if(unimatchin(p->name, aCommand, length))
		{
			break;
		}
		p++;
	}
	if(p_template)
	{
		*p_template = p->matchTemplate;
	}
	return(p->commandNumber);
}

const unichar *CommandName(long command)
{
	Command	*p;

	p = g_commands;
	if(!p)
	{
		InitCommands();
		p = g_commands;
	}
	while(p->name)
	{
		if(command == p->commandNumber)
		{
			return(p->name);
		}
		p++;
	}
	return(NULL);
}
