//Decompiled code. Please respect the original copyright.

void() BsmithPrecache =
{
	precache_model("progs/v_hamr.mdl");
	precache_model("progs/beargib1.mdl");
	precache_model("progs/beargib2.mdl");
	precache_model("progs/beargib3.mdl");
	precache_model("progs/beargib4.mdl");
	precache_model("progs/beartrap.mdl");
	precache_model("progs/v_bear.mdl");
	precache_model("progs/bearbld.mdl");
	precache_model("progs/v_anvil.mdl");
	precache_model("progs/anvil.mdl");
	precache_model("progs/v_ball.mdl");
	precache_model("progs/ballbase.mdl");
	precache_model("progs/balltop.mdl");
	precache_model("progs/shot.mdl");
	precache_sound("bsmith/hurt.wav");
	precache_sound("bsmith/die.wav");
	precache_sound("bsmith/fix.wav");
	precache_sound("bsmith/build.wav");
	precache_sound("bsmith/hamhit.wav");
	precache_sound("bsmith/bdrop_1.wav");
	precache_sound("bsmith/btrap_1.wav");
	precache_sound("bsmith/btrap_3.wav");
	precache_sound("bsmith/draw.wav");
	precache_sound("bsmith/ballfire.wav");
	precache_sound("bsmith/balldraw.wav");
	precache_sound("bsmith/ballhit.wav");
	precache_sound("bsmith/ballkill.wav");
};

void() Bsmith_SetSpawn =
{
	self.max_shells = 300;
	self.max_nails = 250;
	self.max_rockets = STATE_HOME;
	self.max_cells = STATE_HOME;
	self.items = ((((IT_AXE | IT_SHOTGUN) | IT_SUPER_SHOTGUN) | IT_NAILGUN) | IT_ARMOR1);
	self.armorvalue = 50;
	self.armortype = 0.3;
	self.max_type = 0.9;
	self.max_value = 200;
	self.max_bit = IT_ARMOR3;
	self.max_strafe = 280;
	self.max_speed = 300;
	stuffcmd(self, "exec cfg/bsmith.cfg\n");
	self.pl_skin = "stc_bsth";
	self.ammo_shells = 25;
};
void() AnvilGib;

void(entity own) Anvil_TimerRemove =
{
	local string h;

	h = own.netname;
	own.build_finished = time;
	own.saved_time = STATE_HOME;
	own.build_item = world;
	own.th_build = SUB_Null;
	if ((own != self.r_owner))
	{
		centerprint3(own, "Your armor has been repaired\non", h, "'s anvil.\n");
	}
	else
	{
		centerprint(own, "Your armor has been repaired.\n");
	}
	remove(self);
};

void() Anvil_Timer =
{
	local entity own;

	own = self.r_owner;
	if ((own.health <= STATE_HOME))
	{
		remove(self);
		return;
	}
	if ((own.classname != "player"))
	{
		remove(self);
		return;
	}
	if (!T_Armor(own, CLASS_THIEF))
	{
		Anvil_TimerRemove(own);
	}
	else
	{
		if (!T_Armor(own, HOOK_OUT))
		{
			Anvil_TimerRemove(own);
			return;
		}
		own.armorvalue = (own.armorvalue - HOOK_OUT);
		own.build_finished = (time + 9999);
		own.saved_time = (time + 9999);
		own.build_sound = (time + 9999);
		self.nextthink = (time + HOOK_OUT);
		sound(other, CHAN_ITEM, "items/armor1.wav", HOOK_OUT, ATTN_NORM);
	}
};

void(entity p) Anvil_SpawnTimer =
{
	local entity timer;
	local entity temp;

	timer = spawn();
	timer.r_owner = p;
	timer.solid = SOLID_TRIGGER;
	timer.think = Anvil_Timer;
	timer.classname = "daughter";
	timer.th_die = SUB_Remove;
	temp = self;
	self = timer;
	Anvil_Timer();
	self = temp;
};

void() Anvil_Touch =
{
	local string h;

	if ((other.vteam != self.vteam))
	{
		if (MAX_TEAMS)
		{
			if ((other != self.r_owner))
			{
				return;
			}
		}
	}
	if ((other.health <= STATE_HOME))
	{
		return;
	}
	if ((other.classname != "player"))
	{
		return;
	}
	Anvil_SpawnTimer(other);
};

void() AnvilGib =
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
		sound(self, CHAN_BODY, "bsmith/die.wav", HOOK_OUT, ATTN_NORM);
		remove(self);
		return;
	}
	centerprint(own, "Your anvil has been destroyed.\n");
	ThrowGib("progs/shrap1.mdl", (self.health * HOOK_ON));
	ThrowGib("progs/shrap2.mdl", (self.health * HOOK_ON));
	ThrowGib("progs/shrap3.mdl", (self.health * HOOK_ON));
	sound(self, CHAN_BODY, "bsmith/die.wav", HOOK_OUT, ATTN_NORM);
	remove(self);
};

void(entity attacker, float take) AnvilPain =
{
	sound(self, CHAN_BODY, "bsmith/hurt.wav", 0.5, ATTN_NORM);
};

void() Build_Anvil =
{
	local entity y;

	y = self.build_item;
	y.vteam = self.vteam;
	y.touch = Anvil_Touch;
	self.build_finished = time;
	self.saved_time = STATE_HOME;
	self.build_item = world;
	self.th_build = SUB_Null;
};

void() Bsmith_Anvil =
{
	local float temp;

	if ((self.ammo_nails < SVC_INTERMISSION))
	{
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
		return;
	}
	if ((CountDaughters("anvil") > STATE_HOME))
	{
		sprint(self, PRINT_HIGH, "You can have only one anvil at a time.\n");
		return;
	}
	makevectors(self.v_angle);
	v_forward_z = STATE_HOME;
	v_forward = (normalize(v_forward) * FL_DIALOG);
	obj_org = (self.origin + v_forward);
	obj_mins = '-16 -16 -12';
	obj_maxs = '16 16 20';
	temp = CheckArea(self);
	if ((temp == FALSE))
	{
		sprint(self, PRINT_HIGH, "You cannot build there.\n");
		return;
	}
	newmis = spawn();
	self.build_finished = (time + 15);
	self.saved_time = (time + HOOK_OUT);
	self.ammo_nails = (self.ammo_nails - SVC_INTERMISSION);
	self.currentammo = (self.ammo_nails - SVC_INTERMISSION);
	self.th_build = Build_Anvil;
	self.oldorigin = self.origin;
	self.build_item = newmis;
	setorigin(newmis, obj_org);
	newmis.r_owner = self;
	newmis.ammo_nails = SVC_INTERMISSION;
	newmis.item_class = "daughter";
	setmodel(newmis, "progs/anvil.mdl");
	newmis.solid = SOLID_BBOX;
	newmis.takedamage = DAMAGE_YES;
	newmis.angles_y = self.angles_y;
	newmis.th_pain = AnvilPain;
	newmis.health = 800;
	newmis.max_health = 800;
	newmis.movetype = MOVETYPE_TOSS;
	setsize(newmis, obj_mins, obj_maxs);
	newmis.touch = SUB_Null;
	newmis.classname = "building_anvil";
	newmis.netname = "anvil";
	newmis.th_die = AnvilGib;
};
float PK_BT_TIMETOFOLLOW    = 15;
float PK_BT_DMG    = 2;
.float beartrap_time;
.entity beartrap_target;
.float beartrapdmg_time;
.float dodmg;

void(string gibname, float dm) beartrap_throwGib =
{
	local entity new;

	new = spawn();
	new.origin = self.origin;
	setmodel(new, gibname);
	setsize(new, VEC_ORIGIN, VEC_ORIGIN);
	new.velocity = VelocityForDamage(dm);
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_NOT;
	new.avelocity_x = (random() * 600);
	new.avelocity_y = (random() * 600);
	new.avelocity_z = (random() * 600);
	new.think = SUB_Remove;
	new.ltime = time;
	new.nextthink = ((time + MAP_TF) + (random() * MAP_TF));
	new.frame = STATE_HOME;
	new.flags = STATE_HOME;
	new.classname = "beartrap_gib";
	new.owner = self.owner;
	new.think = SUB_Remove;
};

void() beartrapDie =
{
	local float numOfGibs;
	local float dam;

	beartrap_throwGib("progs/beargib1.mdl", -50);
	beartrap_throwGib("progs/beargib2.mdl", -50);
	beartrap_throwGib("progs/beargib3.mdl", -50);
	numOfGibs = (random() * CLASS_THIEF);
	while ((numOfGibs > STATE_HOME))
	{
		dam = (random() * -50);
		beartrap_throwGib("progs/beargib4.mdl", dam);
		numOfGibs = (numOfGibs - HOOK_OUT);
	}
	sound(self, CHAN_AUTO, "bsmith/btrap_3.wav", HOOK_OUT, ATTN_NORM);
	remove(self);
};

void() beartrapFollow =
{
	if ((!self.beartrap_target.beartrap_time || self.beartrap_target.deadflag))
	{
		remove(self);
		return;
	}
	if (((self.origin != self.beartrap_target.origin) || (self.angles != self.owner.angles)))
	{
		setorigin(self, self.beartrap_target.origin);
		self.dodmg = TRUE;
		if ((self.angles != self.owner.angles))
		{
			self.angles = self.owner.angles;
		}
	}
	self.beartrap_time = (self.beartrap_time + 0.1);
	self.beartrapdmg_time = (self.beartrapdmg_time + 0.1);
	if ((self.beartrapdmg_time >= 0.5))
	{
		if (self.dodmg)
		{
			self.beartrap_target.deathtype = "btrap";
			T_Damage(self.beartrap_target, self, self.owner, PK_BT_DMG, STATE_HOME);
			self.dodmg = FALSE;
		}
		self.beartrapdmg_time = STATE_HOME;
	}
	if ((self.beartrap_time > PK_BT_TIMETOFOLLOW))
	{
		self.think = beartrapDie;
	}
};

void() btf =
{
	beartrapFollow();
	self.nextthink = (time + 0.1);
};

void() btf_1 = [ 1, btf_2 ]
{
	beartrapFollow();
};

void() btf_2 = [ 2, btf ]
{
	setmodel(self, "progs/bearbld.mdl");
};

void() beartrapTouch =
{
	if ((pointcontents(self.origin) == CONTENT_SOLID))
	{
		beartrapDie();
		return;
	}
	if ((other.classname == "ballshot"))
	{
		beartrapDie();
	}
	if ((other.classname != "player"))
	{
		return;
	}
	if (((other.vteam == self.vteam) && MAX_TEAMS))
	{
		return;
	}
	if (((other == self.owner) && (self.beartrap_time > time)))
	{
		return;
	}
	other.beartrap_time = HOOK_OUT;
	self.beartrap_target = other;
	self.beartrap_time = STATE_HOME;
	self.beartrapdmg_time = STATE_HOME;
	self.think = btf_1;
	self.nextthink = (time + 0.1);
	self.touch = SUB_Null;
	sound(self, CHAN_AUTO, "bsmith/btrap_1.wav", HOOK_OUT, ATTN_NORM);
};

entity(entity rowner) OldestBeartrap =
{
	local entity t;
	local entity res;
	local float bttime;

	bttime = (time + WEAPON_SPIKES);
	res = world;
	t = find(world, classname, "beartrap");
	while ((t != world))
	{
		if ((t.r_owner == rowner))
		{
			if ((t.beartrap_time < bttime))
			{
				res = t;
				bttime = t.beartrap_time;
			}
		}
		t = find(t, classname, "beartrap");
	}
	return (res);
};

void() beartrap_dropBearTrap =
{
	local entity bt;
	local entity toremove;

	if ((self.ammo_nails < TE_LAVASPLASH))
	{
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
		return;
	}
	if ((CountDaughters("beartrap") > MAP_TF))
	{
		toremove = OldestBeartrap(self);
		if ((toremove != world))
		{
			remove(toremove);
			toremove.voided = HOOK_OUT;
		}
		else
		{
			bprint(PRINT_HIGH, "PROGRAM ERROR #1\n");
			return;
		}
	}
	self.ammo_nails = (self.ammo_nails - TE_LAVASPLASH);
	self.currentammo = (self.ammo_nails - TE_LAVASPLASH);
	bt = spawn();
	bt.owner = self;
	bt.movetype = MOVETYPE_TOSS;
	bt.solid = SOLID_TRIGGER;
	bt.classname = "beartrap";
	bt.takedamage = TRUE;
	bt.health = 50;
	bt.th_die = beartrapDie;
	bt.item_class = "daughter";
	bt.r_owner = self;
	bt.weapon = IT_AXE;
	bt.vteam = self.vteam;
	bt.beartrap_time = (time + MAP_TF);
	bt.think = beartrapDie;
	bt.nextthink = (time + 90);
	setmodel(bt, "progs/beartrap.mdl");
	setsize(bt, '-25 -24 -0', '25 25 8');
	setorigin(bt, self.origin);
	makevectors(self.angles);
	bt.velocity = ((v_forward * (200 + (random() * 100))) + (v_up * (200 + (random() * 100))));
	bt.touch = beartrapTouch;
	sound(self, CHAN_AUTO, "bsmith/bdrop_1.wav", HOOK_OUT, ATTN_NORM);
};

void() Bsmith_SetCurrentAmmo =
{
	player_run();
	self.items = (self.items - (self.items & (((IT_SHELLS | IT_NAILS) | IT_ROCKETS) | IT_CELLS)));
	if ((self.weapon == IT_AXE))
	{
		self.currentammo = STATE_HOME;
		self.weaponmodel = "progs/v_hamr.mdl";
		self.weaponframe = STATE_HOME;
	}
	else
	{
		if ((self.weapon == IT_SHOTGUN))
		{
			self.currentammo = self.ammo_nails;
			self.weaponmodel = "progs/v_bear.mdl";
			self.items = (self.items | IT_NAILS);
			self.weaponframe = STATE_HOME;
		}
		else
		{
			if ((self.weapon == IT_SUPER_SHOTGUN))
			{
				self.currentammo = self.ammo_nails;
				self.weaponmodel = "progs/v_anvil.mdl";
				self.weaponframe = STATE_HOME;
				self.items = (self.items | IT_NAILS);
			}
			else
			{
				if ((self.weapon == IT_NAILGUN))
				{
					if ((CountDaughters("ballista") < HOOK_OUT))
					{
						self.currentammo = self.ammo_nails;
						self.weaponmodel = "progs/v_ball.mdl";
						self.weaponframe = STATE_HOME;
						self.items = (self.items | IT_NAILS);
					}
					else
					{
						self.currentammo = self.ammo_shells;
						self.weaponmodel = "progs/v_clept.mdl";
						self.weaponframe = STATE_HOME;
						self.items = (self.items | IT_SHELLS);
					}
				}
				else
				{
					if ((self.weapon == IT_SUPER_NAILGUN))
					{
						self.currentammo = self.ammo_nails;
						self.weaponframe = STATE_HOME;
						self.items = (self.items | IT_NAILS);
					}
					else
					{
						self.currentammo = STATE_HOME;
						self.weaponmodel = "";
						self.weaponframe = STATE_HOME;
					}
				}
			}
		}
	}
};

float() Bsmith_BestWeapon =
{
	return (IT_AXE);
};

float() Bsmith_CheckNoAmmo =
{
	if ((self.currentammo > STATE_HOME))
	{
		return (TRUE);
	}
	if (((self.ammo_nails < TE_LAVASPLASH) && (self.weapon == IT_SHOTGUN)))
	{
		return (FALSE);
	}
	self.weapon = W_BestWeapon();
	W_SetCurrentAmmo();
	return (FALSE);
};

void() Bsmith_FireHammer =
{
	local vector source;
	local vector org;
	local string strn;
	local entity rown;
	local float y;

	makevectors(self.v_angle);
	source = (self.origin + '0 0 16');
	traceline(source, (source + (v_forward * FL_DIALOG)), FALSE, self);
	if ((trace_fraction == HOOK_OUT))
	{
		return;
	}
	org = (trace_endpos - (v_forward * WEAPON_SPIKES));
	if (trace_ent.takedamage)
	{
		if ((((trace_ent.vteam == self.vteam) && MAX_TEAMS) || (trace_ent.r_owner == self)))
		{
			if ((trace_ent.classname == "player"))
			{
				strn = ftos(trace_ent.armorvalue);
				if (T_Armor(trace_ent, 25))
				{
					sound(trace_ent, CHAN_ITEM, "items/armor1.wav", HOOK_OUT, ATTN_NORM);
				}
				if ((trace_ent.items & IT_ARMOR1))
				{
					centerprint3(self, trace_ent.netname, "\nGreen Armor:", strn);
				}
				else
				{
					if ((trace_ent.items & IT_ARMOR2))
					{
						centerprint3(self, trace_ent.netname, "\nYellow Armor:", strn);
					}
					else
					{
						if ((trace_ent.items & IT_ARMOR3))
						{
							centerprint3(self, trace_ent.netname, "\nRed Armor:", strn);
						}
						else
						{
							if ((trace_ent.armortype == STATE_HOME))
							{
								centerprint3(self, trace_ent.netname, "\nNo Armor", "");
							}
						}
					}
				}
			}
			else
			{
				if ((trace_ent.item_class == "daughter"))
				{
					rown = trace_ent.r_owner;
					if ((rown.build_item == trace_ent))
					{
						rown.build_finished = time;
					}
					y = (trace_ent.max_health - trace_ent.health);
					if ((y > 20))
					{
						y = 20;
					}
					sound(trace_ent, CHAN_AUTO, "bsmith/fix.wav", HOOK_OUT, ATTN_NORM);
					trace_ent.health = (trace_ent.health + y);
					strn = ftos(trace_ent.health);
					if ((rown != self))
					{
						if ((trace_ent.classname == "cauldron"))
						{
							centerprint3(self, rown.netname, "'s cauldron\nHealth: ", strn);
						}
						else
						{
							if ((trace_ent.classname == "teleporter"))
							{
								centerprint3(self, rown.netname, "'s teleporter\nHealth: ", strn);
							}
							else
							{
								if ((trace_ent.classname == "barrel"))
								{
									centerprint3(self, rown.netname, "'s barrel\nHealth: ", strn);
								}
								else
								{
									if ((trace_ent.classname == "ballista"))
									{
										centerprint3(self, rown.netname, "'s ballista\nHealth: ", strn);
									}
								}
							}
						}
					}
					else
					{
						if ((trace_ent.classname == "ballista"))
						{
							centerprint3(self, "Your", " ballista\nHealth: ", strn);
						}
						else
						{
							if ((trace_ent.classname == "anvil"))
							{
								centerprint3(self, "Your", " anvil\nHealth: ", strn);
							}
						}
					}
				}
			}
		}
		else
		{
			trace_ent.axhitme = HOOK_OUT;
			SpawnBlood(org, 20);
			T_Damage(trace_ent, self, self, 20, STATE_HOME);
		}
	}
	else
	{
		sound(self, CHAN_WEAPON, "bsmith/hamhit.wav", HOOK_OUT, ATTN_NORM);
		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte(MSG_MULTICAST, TE_GUNSHOT);
		WriteByte(MSG_MULTICAST, MAP_TF);
		WriteCoord(MSG_MULTICAST, org_x);
		WriteCoord(MSG_MULTICAST, org_y);
		WriteCoord(MSG_MULTICAST, org_z);
		multicast(org, MULTICAST_PVS);
	}
};

void() Bsmith_Attack =
{
	local float r;

	if (!Bsmith_CheckNoAmmo())
	{
		return;
	}
	makevectors(self.v_angle);
	self.show_hostile = (time + HOOK_OUT);
	if ((self.weapon == IT_AXE))
	{
		self.attack_finished = (time + 0.5);
		sound(self, CHAN_WEAPON, "weapons/ax1.wav", HOOK_OUT, ATTN_NORM);
		r = random();
		if ((r < 0.5))
		{
			player_axe1();
		}
		else
		{
			player_axec1();
		}
	}
	else
	{
		if ((self.weapon == IT_SHOTGUN))
		{
			self.attack_finished = (time + 0.5);
			beartrap_dropBearTrap();
		}
		else
		{
			if ((self.weapon == IT_SUPER_SHOTGUN))
			{
				self.attack_finished = (time + 0.7);
				Bsmith_Anvil();
			}
			else
			{
				if ((self.weapon == IT_NAILGUN))
				{
					self.attack_finished = (time + 0.7);
					if ((CountDaughters("ballista") > STATE_HOME))
					{
						player_steal1();
					}
					else
					{
						Bsmith_Ballista();
					}
				}
				else
				{
					if ((self.weapon == IT_SUPER_NAILGUN))
					{
						player_nail1();
					}
				}
			}
		}
	}
};

void() Bsmith_ChangeWeapon =
{
	local float it;
	local float am;
	local float fl;

	it = self.items;
	am = STATE_HOME;
	if ((self.impulse == HOOK_OUT))
	{
		fl = IT_AXE;
	}
	else
	{
		if ((self.impulse == PK_BT_DMG))
		{
			fl = IT_SHOTGUN;
			if ((self.ammo_nails < TE_LAVASPLASH))
			{
				am = HOOK_OUT;
			}
		}
		else
		{
			if ((self.impulse == MAP_TF))
			{
				fl = IT_SUPER_SHOTGUN;
				if ((self.ammo_nails < SVC_INTERMISSION))
				{
					am = HOOK_OUT;
				}
			}
			else
			{
				if ((self.impulse == WEAPON_SPIKES))
				{
					fl = IT_NAILGUN;
					if ((CountDaughters("ballista") > STATE_HOME))
					{
						if ((self.ammo_shells < HOOK_OUT))
						{
							am = HOOK_OUT;
						}
					}
					else
					{
						if ((self.ammo_nails < 60))
						{
							am = HOOK_OUT;
						}
					}
				}
				else
				{
					if ((self.impulse == CLASS_THIEF))
					{
						fl = IT_SUPER_NAILGUN;
						if ((self.ammo_nails < HOOK_OUT))
						{
							am = HOOK_OUT;
						}
					}
				}
			}
		}
	}
	self.impulse = STATE_HOME;
	if (!(self.items & fl))
	{
		sprint(self, PRINT_HIGH, "no weapon.\n");
		return;
	}
	if (am)
	{
		sprint(self, PRINT_HIGH, "not enough ammo.\n");
		return;
	}
	self.weapon = fl;
	W_SetCurrentAmmo();
};

void() BsmithCycleWeaponCommand =
{
	local float it;
	local float am;

	it = self.items;
	self.impulse = STATE_HOME;
	while (HOOK_OUT)
	{
		am = STATE_HOME;
		if ((self.weapon == IT_AXE))
		{
			self.weapon = IT_SHOTGUN;
			if ((self.ammo_nails < TE_LAVASPLASH))
			{
				am = HOOK_OUT;
			}
		}
		else
		{
			if ((self.weapon == IT_SHOTGUN))
			{
				self.weapon = IT_SUPER_SHOTGUN;
				if ((self.ammo_nails < SVC_INTERMISSION))
				{
					am = HOOK_OUT;
				}
			}
			else
			{
				if ((self.weapon == IT_SUPER_SHOTGUN))
				{
					self.weapon = IT_NAILGUN;
					if ((self.ammo_nails < 60))
					{
						am = HOOK_OUT;
					}
				}
				else
				{
					if ((self.weapon == IT_NAILGUN))
					{
						self.weapon = IT_SUPER_NAILGUN;
						if ((self.ammo_nails < HOOK_OUT))
						{
							am = HOOK_OUT;
						}
					}
					else
					{
						if ((self.weapon == IT_SUPER_NAILGUN))
						{
							self.weapon = IT_AXE;
						}
					}
				}
			}
		}
		if (((self.items & self.weapon) && (am == STATE_HOME)))
		{
			W_SetCurrentAmmo();
			return;
		}
	}
};

void() BsmithCycleWeaponReverseCommand =
{
	local float it;
	local float am;

	it = self.items;
	self.impulse = STATE_HOME;
	while (HOOK_OUT)
	{
		am = STATE_HOME;
		if ((self.weapon == IT_SUPER_NAILGUN))
		{
			self.weapon = IT_NAILGUN;
			if ((self.ammo_nails < 60))
			{
				am = HOOK_OUT;
			}
		}
		else
		{
			if ((self.weapon == IT_NAILGUN))
			{
				self.weapon = IT_SUPER_SHOTGUN;
				if ((self.ammo_nails < SVC_INTERMISSION))
				{
					am = HOOK_OUT;
				}
			}
			else
			{
				if ((self.weapon == IT_SUPER_SHOTGUN))
				{
					self.weapon = IT_SHOTGUN;
					if ((self.ammo_nails < TE_LAVASPLASH))
					{
						am = HOOK_OUT;
					}
				}
				else
				{
					if ((self.weapon == IT_SHOTGUN))
					{
						self.weapon = IT_AXE;
					}
					else
					{
						if ((self.weapon == IT_AXE))
						{
							self.weapon = IT_SUPER_NAILGUN;
							if ((self.ammo_nails < HOOK_OUT))
							{
								am = HOOK_OUT;
							}
						}
					}
				}
			}
		}
		if (((it & self.weapon) && (am == STATE_HOME)))
		{
			W_SetCurrentAmmo();
			return;
		}
	}
};

void() BsmithImpulse =
{
	if (((self.impulse >= HOOK_OUT) && (self.impulse <= WEAPON_BIG)))
	{
		Bsmith_ChangeWeapon();
	}
	if ((self.impulse == TE_LAVASPLASH))
	{
		BsmithCycleWeaponCommand();
	}
	if ((self.impulse == TE_BLOOD))
	{
		BsmithCycleWeaponReverseCommand();
	}
	self.impulse = STATE_HOME;
};
