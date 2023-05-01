/*
	server.qc

	server functions (movetarget code)

	Copyright (C) 1996-1997  Id Software, Inc.

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA

*/

void() monster_ogre = {remove(self);};
void() monster_demon1 = {remove(self);};
void() monster_shambler = {remove(self);};
void() monster_knight = {remove(self);};
void() monster_wizard = {remove(self);};
void() monster_dog = {remove(self);};
void() monster_zombie = {remove(self);};
void() monster_boss = {remove(self);};
void() monster_tarbaby = {remove(self);};
void() monster_hell_knight = {remove(self);};
void() monster_fish = {remove(self);};
void() monster_shalrath = {remove(self);};
void() monster_enforcer = {remove(self);};
void() monster_oldone = {remove(self);};
void() event_lightning = {remove(self);};

/*
==============================================================================

MOVETARGET CODE

The angle of the movetarget effects standing and bowing direction, but has no effect on movement, which allways heads to the next target.

targetname
must be present.  The name of this movetarget.

target
the next spot to move to.  If not present, stop here for good.

pausetime
The number of seconds to spend standing or bowing for path_stand or path_bow

==============================================================================
*/

/*
=============
t_movetarget

Something has bumped into a movetarget.  If it is a monster
moving towards it, change the next destination and continue.
==============
*/
void() t_movetarget =
{
local entity    temp;

	if (other.movetarget != self)
		return;
	
	if (other.enemy)
		return;         // fighting, not following a path

	temp = self;
	self = other;
	other = temp;

//dprint ("t_movetarget\n");
	self.goalentity = self.movetarget = find (world, targetname, other.target);
	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	if (!self.movetarget)
	{
		self.pausetime = time + 999999;
		self.th_stand ();
		return;
	}
};



void() movetarget_f =
{
	if (!self.targetname)
		objerror ("monster_movetarget: no targetname");
		
	self.solid = SOLID_TRIGGER;
	self.touch = t_movetarget;
	setsize (self, '-8 -8 -8', '8 8 8');
	
};

/*QUAKED path_corner (0.5 0.3 0) (-8 -8 -8) (8 8 8)
Monsters will continue walking towards the next target corner.
*/
void() path_corner =
{
	movetarget_f ();
};



//============================================================================

void(float num) ClientMapSet =
{
	local string k;
	local string mopname;

	k = ftos(num);
	mopname = infokey(world, k);
	if ((mopname == string_null))
		return;

	stuffcmd(self, "alias ");
	stuffcmd(self, mopname);
	stuffcmd(self, " \"impulse ");
	k = ftos((num + 200));
	stuffcmd(self, k);
	stuffcmd(self, "\"\n");
};

void() ClientMapAlias =
{
	local float r;

	r = 0;
	while (r < 21)
	{
		ClientMapSet(r);
		r = r + 1;
	}
};

void() SUB_Vote =
{
	local float r;
	local string k;

	if (infokey(world, "nextmap") != "vote")
		return;

	if ((votemap == string_null))
	{
		sprint(self, PRINT_HIGH, "No map has been proposed\n");
		return;
	}
	if (self.aflag & FL_VOTED)
	{
		sprint(self, PRINT_HIGH, "You already voted.\n");
		return;
	}

	self.aflag = (self.aflag | FL_VOTED);
	vt_votes = vt_votes + 1;
	r = Num_Players();
	if (vt_votes >= r)
	{
		votemap = infokey(world, "votemap");
		changelevel(votemap);
	}
	else
	{
		bprint(PRINT_HIGH, "Votes in favor:");
		k = ftos(vt_votes);
		bprint(PRINT_HIGH, k);
		bprint(PRINT_HIGH, "\nVotes needed:");
		k = ftos(r);
		bprint(PRINT_HIGH, k);
		bprint(PRINT_HIGH, "\n");
	}
};

void(string hey) SUB_Propose =
{
	local entity t;

	votemap = hey;
	extra = hey;
	vt_votes = 1;
	t = find(world, classname, "player");
	while (t != world)
	{
		t.aflag = t.aflag - (t.aflag & FL_VOTED);
		t = find(t, classname, "player");
	}

	self.aflag = self.aflag | FL_VOTED;
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " proposes going to ");
	bprint(PRINT_HIGH, hey);
	votemap = hey;
	bprint(PRINT_HIGH, "\nType 'yes' on the console to agree\n");
	localcmd("localinfo votemap ");
	localcmd(votemap);
	localcmd("\n");

	if (vt_votes >= Num_Players())
		changelevel(hey);
};

void(float y) ProposeMap =
{
	local string mopname;
	local string k;

	if (infokey(world, "nextmap") != "vote")
		return;
	if (y < 200 || y >= 221)
		return;

	y = y - 200;
	k = ftos(y);
	mopname = infokey(world, k);
	if (mopname == string_null)
		return;

	SUB_Propose(mopname);
};

void() MapList =
{
	local float r;
	local string d;

	r = 0;
	sprint(self, PRINT_HIGH, "Maps available on this server:\n");
	if (infokey(world, "nextmap") == "vote")
		sprint(self, PRINT_HIGH, "To vote for a map, type it's name\n");

	sprint(self, PRINT_HIGH, "----------------------\n");
	while (r < 21)
	{
		d = ftos(r);
		d = infokey(world, d);
		if (d != string_null)
		{
			sprint(self, PRINT_HIGH, d);
			sprint(self, PRINT_HIGH, "\n");
		}
		r = r + 1;
	}
};
