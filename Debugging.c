/*
 *  Debugging.c
 *  xlogo
 *
 *  Created by Jens Bauer on Fri Nov 21 2003.
 *  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
 *
 */

#include <stdio.h>
#include <stdlib.h>

#include "Debugging.h"

#if (defined(DEBUGFLAG) && DEBUGFLAG)
typedef struct CounterObject CounterObject;
struct CounterObject
{
	CounterObject	*next;
	const char		*name;
	unsigned long	count;
};

static CounterObject	*g_counter_objects = NULL;

CounterObject *find_object_named(const char *name)
{
	CounterObject			*travel;

	travel = g_counter_objects;
	while(travel)
	{
		if(name == travel->name)
		{
			break;
		}
		travel = travel->next;
	}
	return(travel);
}

CounterObject *get_object_named(const char *name)
{
	CounterObject			*object;

	object = find_object_named(name);
	if(NULL == object)
	{
		object = malloc(sizeof(CounterObject));
		if(object)
		{
			object->next = g_counter_objects;
			object->name = name;
			object->count = 0;
			g_counter_objects = object;
		}
	}
	return(object);
}

void increment_object_count(const char *name)
{
	CounterObject	*object;

	object = get_object_named(name);
	if(object)
	{
		object->count++;
	}
}

void decrement_object_count(const char *name)
{
	CounterObject	*object;

	object = get_object_named(name);
	if(object)
	{
		object->count--;
	}
}

unsigned long get_object_count(const char *name)
{
	CounterObject	*object;

	object = find_object_named(name);
	if(object)
	{
		return(object->count);
	}
	return(0);
}

void dump_object_count()
{
	CounterObject	*travel;

	travel = g_counter_objects;
	while(travel)
	{
		fprintf(stderr, "number of objects named \"%s\": %lu\n", travel->name, travel->count);
		travel = travel->next;
	}
}
#endif
