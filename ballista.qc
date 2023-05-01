//Decompiled code. Please respect the original copyright.
void() BallistaThink;

void() bal_ready =
{
	self.weapon = HOOK_OUT;
	self.think = BallistaThink;
	self.nextthink = (time + 0.1);
};

void() bal_reload1 = [ 0, bal_reload2 ]
{
	self.weapon = HOOK_ON;
};

void() bal_reload2 = [ 1, bal_reload3 ]
{
};

void() bal_reload3 = [ 2, bal_reload4 ]
{
};

void() bal_reload4 = [ 3, bal_reload5 ]
{
};

void() bal_reload5 = [ 4, bal_reload6 ]
{
};

void() bal_reload6 = [ 5, bal_ready ]
{
};

void() FireBallista =
{
	local vector phil;

	if ((self.owner.ammo_shells < HOOK_OUT))
	{
		sound(self, CHAN_WEAPON, "bsmith/draw.wav", HOOK_OUT, ATTN_NORM);
		self.weapon = STATE_HOME;
		return;
	}
	sound(self, CHAN_WEAPON, "bsmith/ballfire.wav", HOOK_OUT, ATTN_NORM);
	self.weapon = STATE_HOME;
	newmis = spawn();
	newmis.owner = self.owner;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	phil = self.angles;
	phil_x = (360 - phil_x);
	makevectors(phil);
	newmis.velocity = (v_forward * 1000);
	newmis.angles = vectoangles(newmis.velocity);
	newmis.rad_time = 100;
	sound(self, CHAN_WEAPON, "bsmith/ballfire.wav", HOOK_OUT, ATTN_NORM);
	newmis.touch = Arrow_Touch;
	newmis.voided = STATE_HOME;
	newmis.nextthink = (time + CLASS_THIEF);
	newmis.think = SUB_Remove;
	newmis.classname = "ballshot";
	self.owner.ammo_shells = (self.owner.ammo_shells - HOOK_OUT);
	setmodel(newmis, "progs/shot.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(newmis, (self.origin + (v_forward * WEAPON_BIG)));
};

void() BallistaThink =
{
	local entity head;
	local vector aimvect;

	if ((self.weapon == STATE_HOME))
	{
		bal_reload1();
	}
	if ((self.weapon != HOOK_OUT))
	{
		self.nextthink = (time + 0.07);
		return;
	}
	self.enemy = world;
	self.oldenemy = world;
	head = findradius(self.origin, 1000);
	while (head)
	{
		if (((head.classname == "player") || (head.item_class == "daughter")))
		{
			if (((((head.vteam != self.vteam) && MAX_TEAMS) && (head.vteam != STATE_HOME)) || ((!MAX_TEAMS && (head != self.r_owner)) && (head.r_owner != self.r_owner))))
			{
				if (CanDamage(head, self))
				{
					if ((head.health > STATE_HOME))
					{
						if (head.takedamage)
						{
							if ((head.class == CLASS_THIEF))
							{
								self.oldenemy = head;
							}
							else
							{
								self.enemy = head;
							}
						}
					}
				}
			}
		}
		head = head.chain;
	}
	if ((self.enemy == world))
	{
		self.enemy = self.oldenemy;
	}
	if ((self.enemy != world))
	{
		aimvect = normalize((self.enemy.origin - self.origin));
		aimvect = vectoangles(aimvect);
		aimvect_z = STATE_HOME;
		if ((self.angles != aimvect))
		{
			self.angles = aimvect;
		}
		else
		{
			FireBallista();
		}
	}
	self.nextthink = (time + 0.07);
};

void() BallistaGib =
{
	local entity own;

	own = self.r_owner;
	if ((own.build_item == self))
	{
		own.build_finished = time;
		own.saved_time = STATE_HOME;
		own.build_item = world;
		own.th_build = SUB_Null;
		ThrowGib("progs/shrap1.mdl", (self.health * HOOK_ON));
		ThrowGib("progs/shrap2.mdl", (self.health * HOOK_ON));
		ThrowGib("progs/shrap3.mdl", (self.health * HOOK_ON));
		sound(self, CHAN_BODY, "bsmith/ballkill.wav", HOOK_OUT, ATTN_NORM);
		if ((self.owner.classname == "balltop"))
		{
			remove(self.owner);
		}
		remove(self);
		return;
	}
	centerprint(own, "Your ballista has been destroyed.\n");
	ThrowGib("progs/shrap1.mdl", (self.health * HOOK_ON));
	ThrowGib("progs/shrap2.mdl", (self.health * HOOK_ON));
	ThrowGib("progs/shrap3.mdl", (self.health * HOOK_ON));
	sound(self, CHAN_BODY, "bsmith/ballkill.wav", HOOK_OUT, ATTN_NORM);
	if ((self.owner.classname == "balltop"))
	{
		remove(self.owner);
	}
	remove(self);
};

void(entity attacker, float take) BallistaPain =
{
	if ((attacker != self))
	{
		sound(self, CHAN_BODY, "bsmith/ballhit.wav", 0.5, ATTN_NORM);
	}
};

void() Build_Ballista =
{
	local entity y;
	local entity top;

	y = self.build_item;
	y.vteam = self.vteam;
	self.build_item = world;
	top = spawn();
	setorigin(top, (y.origin + '0 0 35'));
	setsize(top, VEC_ORIGIN, VEC_ORIGIN);
	top.movetype = MOVETYPE_NOCLIP;
	top.solid = SOLID_NOT;
	top.owner = y;
	y.owner = top;
	y.r_owner = self;
	setmodel(top, "progs/balltop.mdl");
	top.angles_y = self.angles_y;
	y.enemy = top;
	top.think = BallistaThink;
	top.nextthink = (time + 0.07);
	top.r_owner = self;
	top.vteam = self.vteam;
	top.classname = "balltop";
	sound(top, CHAN_WEAPON, "bsmith/balldraw.wav", HOOK_OUT, ATTN_NORM);
};

void() Bsmith_Ballista =
{
	local float temp;

	if ((CountDaughters("ballista") > STATE_HOME))
	{
		sprint(self, PRINT_HIGH, "You can have only one ballista at a time.\n");
		return;
	}
	makevectors(self.v_angle);
	v_forward_z = STATE_HOME;
	v_forward = (normalize(v_forward) * FL_DIALOG);
	obj_org = (self.origin + v_forward);
	obj_mins = '-16 -16 -4';
	obj_maxs = '16 16 34';
	temp = CheckArea(self);
	if ((temp == FALSE))
	{
		sprint(self, PRINT_HIGH, "You cannot build there.\n");
		return;
	}
	newmis = spawn();
	self.build_finished = (time + 15);
	self.saved_time = (time + HOOK_OUT);
	self.ammo_nails = (self.ammo_nails - 60);
	self.currentammo = (self.ammo_nails - 60);
	self.th_build = Build_Ballista;
	self.oldorigin = self.origin;
	self.build_item = newmis;
	setorigin(newmis, obj_org);
	newmis.r_owner = self;
	newmis.ammo_nails = 60;
	newmis.ammo_shells = self.ammo_shells;
	newmis.max_shells = 150;
	if ((newmis.ammo_shells > newmis.max_shells))
	{
		newmis.ammo_shells = newmis.max_shells;
	}
	self.ammo_shells = (self.ammo_shells - newmis.ammo_shells);
	newmis.item_class = "daughter";
	setmodel(newmis, "progs/ballbase.mdl");
	newmis.solid = SOLID_BBOX;
	newmis.takedamage = DAMAGE_YES;
	newmis.th_pain = BallistaPain;
	newmis.health = 400;
	newmis.max_health = 400;
	newmis.movetype = MOVETYPE_TOSS;
	setsize(newmis, obj_mins, obj_maxs);
	newmis.touch = SUB_Null;
	newmis.classname = "building_ballista";
	newmis.netname = "ballista";
	newmis.th_die = BallistaGib;
};
