/*
	weapons.qc

	weapon and weapon hit functions

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

void (entity targ, entity inflictor, entity attacker, float damage, float dflags) T_Damage;
void () player_run;
void(entity bomb, entity attacker, float rad, entity ignore, string dtype, float dflags) T_RadiusDamage;
void(vector org, float damage) SpawnBlood;
void() SuperDamageSound;

void(float y) ProposeMap;
void() SUB_Vote;

// called by worldspawn
void() W_Precache =
{
	precache_sound("weapons/ric1.wav");    // ricochet (used in c code)
	precache_sound("weapons/ric2.wav");    // ricochet (used in c code)
	precache_sound("weapons/ric3.wav");    // ricochet (used in c code)
	precache_sound("weapons/spike2.wav");  // super spikes
	precache_sound("weapons/tink1.wav");   // spikes tink (used in c code)
	precache_sound("hknight/slash1.wav");
	precache_sound("misc/help1.wav");
	precache_sound("misc/help2.wav");
	precache_sound("misc/sright.wav");
	precache_sound("misc/sleft.wav");
	precache_sound("misc/wleft.wav");
	precache_sound("misc/wright.wav");
	precache_sound("misc/rleft.wav");
	precache_sound("misc/rright.wav");	

	ArcherPrecache();

	AlchPrecache();

	BarrelPrecache();

	KnightPrecache();

	BsmithPrecache();

	ThiefPrecache();

	WizardPrecache();
};

float() crandom =
{
	return 2*(random() - 0.5);
};

/*
================
W_FireAxe
================
*/
void() W_FireAxe =
{
	if ((self.class == CLASS_ARCHER))
	{
		Archer_FireAxe();
	}
	if ((self.class == CLASS_KNIGHT))
	{
		Knight_FireSword();
	}
	if ((self.class == CLASS_ALCH))
	{
		Alch_FirePotion();
	}
	if ((self.class == CLASS_THIEF))
	{
		Thief_FireKnife();
	}
	if ((self.class == CLASS_BSMITH))
	{
		Bsmith_FireHammer();
	}
	if ((self.class == CLASS_WIZARD))
	{
		Archer_FireAxe();
	}
};


//============================================================================


vector() wall_velocity =
{
	local vector    vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};


/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	local   entity missile;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');            
	setorigin (missile, org);
};

/*
================
SpawnBlood
================
*/
void(vector org, float damage) SpawnBlood =
{
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_BLOOD);
	WriteByte (MSG_MULTICAST, 1);
	WriteCoord (MSG_MULTICAST, org_x);
	WriteCoord (MSG_MULTICAST, org_y);
	WriteCoord (MSG_MULTICAST, org_z);
	multicast (org, MULTICAST_PVS);
};

/*
================
spawn_touchblood
================
*/
void(float damage) spawn_touchblood =
{
	local vector    vel;

	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel*0.01, damage);
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity  multi_ent;
float   multi_damage;

vector  blood_org;
float   blood_count;

vector  puff_org;
float   puff_count;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
	blood_count = 0;
	puff_count = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	T_Damage (multi_ent, self, self, multi_damage, DAMAGE_NO);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

void() Multi_Finish =
{
	if (puff_count)
	{
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_GUNSHOT);
		WriteByte (MSG_MULTICAST, puff_count);
		WriteCoord (MSG_MULTICAST, puff_org_x);
		WriteCoord (MSG_MULTICAST, puff_org_y);
		WriteCoord (MSG_MULTICAST, puff_org_z);
		multicast (puff_org, MULTICAST_PVS);
	}

	if (blood_count)
	{
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_BLOOD);
		WriteByte (MSG_MULTICAST, blood_count);
		WriteCoord (MSG_MULTICAST, blood_org_x);
		WriteCoord (MSG_MULTICAST, blood_org_y);
		WriteCoord (MSG_MULTICAST, blood_org_z);
		multicast (puff_org, MULTICAST_PVS);
	}
};


/*
===============================================================================
LIGHTNING
===============================================================================
*/

void(entity from, float damage) LightningHit =
{
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_LIGHTNINGBLOOD);
	WriteCoord (MSG_MULTICAST, trace_endpos_x);
	WriteCoord (MSG_MULTICAST, trace_endpos_y);
	WriteCoord (MSG_MULTICAST, trace_endpos_z);
	multicast (trace_endpos, MULTICAST_PVS);

	T_Damage (trace_ent, from, from, damage, DAMAGE_NO);
};

/*
=================
LightningDamage
=================
*/
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	local entity            e1, e2;
	local vector            f;
	
	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline (p1, p2, FALSE, self);

	if (trace_ent.takedamage)
	{
		LightningHit (from, damage);
		if (self.classname == "player")
		{
			if (other.classname == "player")
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline (p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
		LightningHit (from, damage);
	}
	e2 = trace_ent;

	traceline (p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		LightningHit (from, damage);
	}
};


//=============================================================================

void() spike_touch;
void() superspike_touch;


/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.voided=0;
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);               
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};



.float hit_z;
void() spike_touch =
{
local float rand;
	if (other == self.owner)
		return;

	if (self.voided) {
		return;
	}
	self.voided = 1;

	if (other.solid == SOLID_TRIGGER)
		return; // trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (9);
		other.deathtype = "nail";

		if ((self.classname == "wizspike") && (self.owner.vteam != other.vteam) && MAX_TEAMS)
		{
			other.poison = other.poison + 15;
			other.enemy = self.owner;
		}

		if (self.classname == "knightspike")
			T_Damage(other, self, self.owner, 35, DAMAGE_NO);
		else
			T_Damage(other, self, self.owner, 20, DAMAGE_NO);
	}
	else
	{
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		if (self.classname == "wizspike")
			WriteByte (MSG_MULTICAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte (MSG_MULTICAST, TE_KNIGHTSPIKE);
		else
			WriteByte (MSG_MULTICAST, TE_SPIKE);
		WriteCoord (MSG_MULTICAST, self.origin_x);
		WriteCoord (MSG_MULTICAST, self.origin_y);
		WriteCoord (MSG_MULTICAST, self.origin_z);
		multicast (self.origin, MULTICAST_PHS);
	}

	remove(self);

};

void() superspike_touch =
{
local float rand;
	if (other == self.owner)
		return;

	if (self.voided) {
		return;
	}
	self.voided = 1;


	if (other.solid == SOLID_TRIGGER)
		return; // trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (18);
		other.deathtype = "supernail";
		T_Damage (other, self, self.owner, 18, DAMAGE_NO);
	}
	else
	{
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_SUPERSPIKE);
		WriteCoord (MSG_MULTICAST, self.origin_x);
		WriteCoord (MSG_MULTICAST, self.origin_y);
		WriteCoord (MSG_MULTICAST, self.origin_z);
		multicast (self.origin, MULTICAST_PHS);
	}

	remove(self);

};


/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void() W_SetCurrentAmmo =
{
	if ((self.build_finished > time))
	{
		return;
	}
	if ((self.class == CLASS_OBSERVER))
	{
		return;
	}
	if ((self.health > STATE_HOME))
	{
		player_run();
	}
	if ((self.class == CLASS_ARCHER))
	{
		Archer_SetCurrentAmmo();
	}
	if ((self.class == CLASS_ALCH))
	{
		Alch_SetCurrentAmmo();
	}
	if ((self.class == CLASS_BARREL))
	{
		Barrel_SetCurrentAmmo();
	}
	if ((self.class == CLASS_BSMITH))
	{
		Bsmith_SetCurrentAmmo();
	}
	if ((self.class == CLASS_KNIGHT))
	{
		Knight_SetCurrentAmmo();
	}
	if ((self.class == CLASS_WIZARD))
	{
		Wizard_SetCurrentAmmo();
	}
	if ((self.class == CLASS_THIEF))
	{
		Thief_SetCurrentAmmo();
	}
};

float() W_BestWeapon =
{
	if ((self.class == CLASS_ARCHER))
	{
		return (Archer_BestWeapon());
	}
	if ((self.class == CLASS_ALCH))
	{
		return (Alch_BestWeapon());
	}
	if ((self.class == CLASS_BARREL))
	{
		return (Barrel_BestWeapon());
	}
	if ((self.class == CLASS_BSMITH))
	{
		return (Bsmith_BestWeapon());
	}
	if ((self.class == CLASS_KNIGHT))
	{
		return (Knight_BestWeapon());
	}
	if ((self.class == CLASS_WIZARD))
	{
		return (Wizard_BestWeapon());
	}
	if ((self.class == CLASS_THIEF))
	{
		return (Thief_BestWeapon());
	}
};

float() W_CheckNoAmmo =
{
	if ((self.class == CLASS_ARCHER))
	{
		return (Archer_CheckNoAmmo());
	}
	if ((self.class == CLASS_ALCH))
	{
		return (Alch_CheckNoAmmo());
	}
	if ((self.class == CLASS_BARREL))
	{
		return (Barrel_CheckNoAmmo());
	}
	if ((self.class == CLASS_BSMITH))
	{
		return (Bsmith_CheckNoAmmo());
	}
	if ((self.class == CLASS_KNIGHT))
	{
		return (Knight_CheckNoAmmo());
	}
	if ((self.class == CLASS_WIZARD))
	{
		return (Wizard_CheckNoAmmo());
	}
	if ((self.class == CLASS_THIEF))
	{
		return (Thief_CheckNoAmmo());
	}
};

/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void() W_Attack =
{
	if ((self.class == CLASS_OBSERVER))
	{
		return;
	}
	if ((self.build_finished > time))
	{
		return;
	}
	if ((self.class == CLASS_ARCHER))
	{
		Archer_Attack();
	}
	if ((self.class == CLASS_ALCH))
	{
		Alch_Attack();
	}
	if ((self.class == CLASS_BARREL))
	{
		Barrel_Attack();
	}
	if ((self.class == CLASS_BSMITH))
	{
		Bsmith_Attack();
	}
	if ((self.class == CLASS_KNIGHT))
	{
		Knight_Attack();
	}
	if ((self.class == CLASS_WIZARD))
	{
		Wizard_Attack();
	}
	if ((self.class == CLASS_THIEF))
	{
		Thief_Attack();
	}
};

void(float new) ClassString =
{
	if ((new == CLASS_ARCHER))
	{
		sprint(self, PRINT_MEDIUM, "n archer");
	}
	else
	{
		if ((new == CLASS_KNIGHT))
		{
			sprint(self, PRINT_MEDIUM, " knight");
		}
		else
		{
			if ((new == CLASS_ALCH))
			{
				sprint(self, PRINT_MEDIUM, "n alchemist");
			}
			else
			{
				if ((new == CLASS_BARREL))
				{
					sprint(self, PRINT_MEDIUM, " barrel man");
				}
				else
				{
					if ((new == CLASS_BSMITH))
					{
						sprint(self, PRINT_MEDIUM, " blacksmith");
					}
					else
					{
						if ((new == CLASS_WIZARD))
						{
							sprint(self, PRINT_MEDIUM, " wizard");
						}
						else
						{
							if ((new == CLASS_THIEF))
							{
								sprint(self, PRINT_MEDIUM, " thief");
							}
							else
							{
								sprint(self, PRINT_MEDIUM, " unknown class");
							}
						}
					}
				}
			}
		}
	}
};

void(float new) ChangeClass =
{
	if ((self.newclass == new))
	{
		return;
	}
	if (!self.class)
	{
		return;
	}
	self.newclass = new;
	sprint(self, PRINT_MEDIUM, "After dying, you will return as a");
	ClassString(self.newclass);
	sprint(self, PRINT_MEDIUM, ".\n");
	self.random_class = STATE_HOME;
};

void() RandomClass =
{
	if (!self.class)
	{
		return;
	}
	self.random_class = (random() * CLASS_BSMITH);
	self.random_class = floor(self.random_class);
	self.random_class = (self.random_class + HOOK_OUT);
	sprint(self, PRINT_MEDIUM, "After dying, you will return as a");
	ClassString(self.random_class);
	sprint(self, PRINT_MEDIUM, " (random).\n");
};
void() MapList;

void() Dead_Impulse =
{
	if ((self.impulse == 90))
	{
		ChangeClass(CLASS_ARCHER);
	}
	if ((self.impulse == 91))
	{
		ChangeClass(CLASS_KNIGHT);
	}
	if ((self.impulse == 92))
	{
		ChangeClass(CLASS_BARREL);
	}
	if ((self.impulse == 93))
	{
		ChangeClass(CLASS_ALCH);
	}
	if ((self.impulse == 94))
	{
		ChangeClass(CLASS_THIEF);
	}
	if ((self.impulse == 95))
	{
		ChangeClass(CLASS_BSMITH);
	}
	if ((self.impulse == 96))
	{
		ChangeClass(CLASS_WIZARD);
	}
	self.impulse = STATE_HOME;
};

void() ImpulseCommands =
{
	if (!self.impulse)
	{
		return;
	}
	if ((self.aflag & FL_MENU))
	{
		self.th_menu();
		self.impulse = STATE_HOME;
		return;
	}
	ProposeMap(self.impulse);
	if ((self.impulse == 29))
	{
		SUB_Vote();
	}
	if ((self.impulse == 28))
	{
		MapList();
	}
	if ((self.impulse == 254))
	{
		IdPlayer();
	}
	if ((self.impulse == 253))
	{
		SayHelp();
	}
	if ((self.impulse == TE_LIGHTNINGBLOOD))
	{
		DestroyCommand();
	}
	if ((self.impulse == 90))
	{
		ChangeClass(CLASS_ARCHER);
	}
	if ((self.impulse == 91))
	{
		ChangeClass(CLASS_KNIGHT);
	}
	if ((self.impulse == 92))
	{
		ChangeClass(CLASS_BARREL);
	}
	if ((self.impulse == 93))
	{
		ChangeClass(CLASS_ALCH);
	}
	if ((self.impulse == 94))
	{
		ChangeClass(CLASS_THIEF);
	}
	if ((self.impulse == 95))
	{
		ChangeClass(CLASS_BSMITH);
	}
	if ((self.impulse == 96))
	{
		ChangeClass(CLASS_WIZARD);
	}
	if ((self.impulse == 97))
	{
		RandomClass();
	}
	if ((self.class == CLASS_ARCHER))
	{
		ArcherImpulse();
	}
	if ((self.class == CLASS_ALCH))
	{
		AlchImpulse();
	}
	if ((self.class == CLASS_BARREL))
	{
		BarrelImpulse();
	}
	if ((self.class == CLASS_BSMITH))
	{
		BsmithImpulse();
	}
	if ((self.class == CLASS_KNIGHT))
	{
		KnightImpulse();
	}
	if ((self.class == CLASS_WIZARD))
	{
		WizardImpulse();
	}
	if ((self.class == CLASS_THIEF))
	{
		ThiefImpulse();
	}
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	if (time < self.attack_finished)
		return;

	if ((self.class == CLASS_THIEF))
	{
		if (((!self.button0 && (self.hook & HOOK_ON)) && (self.weapon == IT_SHOTGUN)))
		{
			self.hook = (self.hook - (self.hook & HOOK_ON));
			player_run();
			return;
		}
	}

	ImpulseCommands ();
	
// check for attack
	if (self.button0)
	{
		SuperDamageSound ();
		W_Attack ();
	}
};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
	return;
};


