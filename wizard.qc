//Decompiled code. Please respect the original copyright.

void() WizardPrecache =
{
	precache_model("progs/portal.mdl");
	precache_sound("wizard/port1.wav");
	precache_sound("wizard/port2.wav");
	precache_sound("wizard/chant.wav");
	precache_sound("shalrath/attack2.wav");
	precache_model("progs/v_staff.mdl");
	precache_model("progs/v_orb2.mdl");
	precache_model("progs/v_spike.mdl");
	precache_model("progs/v_cod2.mdl");
};

void() Wizard_SetSpawn =
{
	self.max_shells = STATE_HOME;
	self.max_nails = 60;
	self.max_rockets = STATE_HOME;
	self.max_cells = 200;
	self.items = (((IT_AXE | IT_SHOTGUN) | IT_SUPER_SHOTGUN) | IT_ARMOR1);
	self.armorvalue = 50;
	self.armortype = 0.3;
	self.max_type = 0.3;
	self.max_value = 100;
	self.max_bit = IT_ARMOR1;
	self.max_strafe = 280;
	self.max_speed = 300;
	stuffcmd(self, "exec cfg/wizard.cfg\n");
	self.pl_skin = "base";
};
void() TeleporterGib;

void() w_open1 = [ 0, w_open2 ]
{
};

void() w_open2 = [ 1, w_open3 ]
{
};

void() w_open3 = [ 2, w_open4 ]
{
};

void() w_open4 = [ 3, w_ani1 ]
{
};

void() w_ani1 = [ 4, w_ani2 ]
{
	self.skin = MAP_TF;
};

void() w_ani2 = [ 5, w_ani3 ]
{
	self.skin = PK_BT_DMG;
};

void() w_ani3 = [ 6, w_ani4 ]
{
	self.skin = HOOK_OUT;
};

void() w_ani4 = [ 7, w_ani5 ]
{
	self.skin = STATE_HOME;
};

void() w_ani5 = [ 6, w_ani6 ]
{
	self.skin = HOOK_OUT;
};

void() w_ani6 = [ 5, w_ani1 ]
{
	self.skin = PK_BT_DMG;
};

void() shot_wizard_touch =
{
	local float damg;

	if ((other == self.owner))
	{
		return;
	}
	if (self.voided)
	{
		return;
	}
	self.voided = HOOK_OUT;
	if ((pointcontents(self.origin) == CONTENT_SKY))
	{
		remove(self);
		return;
	}
	damg = (SVC_INTERMISSION + (random() * 20));
	if ((other.health > STATE_HOME))
	{
		other.deathtype = "rocket";
		T_Damage(other, self, self.owner, damg, STATE_HOME);
	}
	T_RadiusDamage(self, self.owner, 120, other, "rocket", STATE_HOME);
	self.origin = (self.origin - (WEAPON_BIG * normalize(self.velocity)));
	WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte(MSG_MULTICAST, TE_TAREXPLOSION);
	WriteCoord(MSG_MULTICAST, self.origin_x);
	WriteCoord(MSG_MULTICAST, self.origin_y);
	WriteCoord(MSG_MULTICAST, self.origin_z);
	multicast(self.origin, MULTICAST_PHS);
	remove(self);
};

void() Missile_Guided =
{
	local vector gd;

	if ((time > self.attack_finished))
	{
		remove(self);
		return;
	}
	makevectors(self.owner.v_angle);
	traceline(self.owner.origin, (self.owner.origin + (v_forward * 4200)), FALSE, self);
	gd = normalize((trace_endpos - self.origin));
	self.velocity = (gd * 800);
	self.nextthink = (time + 0.1);
};

void() fire_wizard_sceptar =
{
	if ((deathmatch != WEAPON_SPIKES))
	{
		self.ammo_cells = (self.ammo_cells - HOOK_OUT);
		self.currentammo = (self.ammo_cells - HOOK_OUT);
	}
	sound(self, CHAN_WEAPON, "shalrath/attack2.wav", HOOK_OUT, ATTN_NORM);
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_SMALLKICK);
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	makevectors(self.v_angle);
	newmis.velocity = aim(self, 800);
	newmis.velocity = (newmis.velocity * 800);
	newmis.angles = vectoangles(newmis.velocity);
	newmis.touch = shot_wizard_touch;
	newmis.voided = STATE_HOME;
	newmis.attack_finished = (time + CLASS_BSMITH);
	newmis.nextthink = (time + 0.1);
	newmis.think = Missile_Guided;
	newmis.classname = "rocket";
	setmodel(newmis, "progs/v_spike.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(newmis, ((self.origin + (v_forward * WEAPON_BIG)) + '0 0 16'));
};

entity() T_FindLink =
{
	local entity t;

	t = find(world, classname, "teleporter");
	while ((t != world))
	{
		if ((t != self))
		{
			if ((pointcontents(t.origin) == CONTENT_SOLID))
			{
				remove(t);
			}
			else
			{
				if (((t.r_owner == self.r_owner) && (self.item_class == "daughter")))
				{
					return (t);
				}
			}
		}
		t = find(t, classname, "teleporter");
	}
	return (world);
};

void() TeleporterNoTelefrag =
{
	self.owner = world;
	self.takedamage = DAMAGE_YES;
	spawn_tdeath(self.origin, self);
	force_retouch = PK_BT_DMG;
	w_ani1();
};

void() T_Teleport_Touch =
{
	local entity t;
	local vector org;
	local vector p;

	if (((other.health < HOOK_OUT) || (other.solid != SOLID_SLIDEBOX)))
	{
		return;
	}
	if ((self.beartrap_time >= time))
	{
		return;
	}
	if (((other.vteam != self.vteam) && MAX_TEAMS))
	{
		if ((other.flags & FL_ONGROUND))
		{
			p = normalize((other.origin - self.origin));
			other.velocity = (other.velocity + (p * 75));
		}
		centerprint(other, "You cannot enter enemy portal.");
		sound(self, CHAN_BODY, "wizard/port2.wav", HOOK_OUT, ATTN_NORM);
		return;
	}
	t = T_FindLink();
	if ((t == world))
	{
		if ((self.cheating < time))
		{
			centerprint(other, "This teleporter hasn't been\nactivated yet.");
			sound(self, CHAN_BODY, "wizard/port2.wav", HOOK_OUT, ATTN_NORM);
			self.cheating = (time + HOOK_OUT);
			if ((other.flags & FL_ONGROUND))
			{
				p = normalize((other.origin - self.origin));
				other.velocity = (other.velocity + (p * 100));
			}
			return;
		}
		return;
	}
	self.beartrap_time = (time + PK_BT_DMG);
	T_Damage(self, self, self, PK_BT_DMG, STATE_HOME);
	spawn_tfog(other.origin);
	makevectors(t.angles);
	org = (t.origin + (FL_SHEILD * v_forward));
	t.owner = other;
	t.takedamage = DAMAGE_NO;
	t.think = TeleporterNoTelefrag;
	t.nextthink = (time + 0.2);
	t.beartrap_time = (t.nextthink + PK_BT_DMG);
	spawn_tfog(org);
	spawn_tdeath(t.origin, other);
	if (!other.health)
	{
		other.origin = t.origin;
		other.velocity = ((v_forward * other.velocity_x) + (v_forward * other.velocity_y));
		return;
	}
	setorigin(other, (org + '0 0 16'));
	other.angles = t.angles;
	if ((other.classname == "player"))
	{
		other.fixangle = HOOK_OUT;
		other.teleport_time = (time + 0.7);
		if ((other.flags & FL_ONGROUND))
		{
			other.flags = (other.flags - FL_ONGROUND);
		}
		other.velocity = (v_forward * 300);
	}
	other.flags = (other.flags - (other.flags & FL_ONGROUND));
};

void() TeleporterGib =
{
	local entity own;

	own = self.r_owner;
	if ((own.build_item == self))
	{
		own.build_finished = time;
		own.saved_time = STATE_HOME;
		own.th_build = SUB_Null;
		own.build_item = world;
		remove(self);
		return;
	}
	centerprint(own, "Your teleporter has been destroyed.");
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_TAREXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	remove(self);
};

void(entity attacker, float take) TeleporterPain =
{
	if ((attacker != self))
	{
		sound(self, CHAN_BODY, "weapons/lhit.wav", HOOK_OUT, ATTN_NORM);
	}
};

void() Build_Teleporter =
{
	local entity y;
	local entity oself;

	y = self.build_item;
	y.vteam = self.vteam;
	y.item_class = "daughter";
	y.touch = T_Teleport_Touch;
	self.build_item = world;
	sound(y, CHAN_BODY, "wizard/port1.wav", HOOK_OUT, ATTN_NORM);
	oself = self;
	self = y;
	w_open1();
	self = oself;
};

void() Wizard_Teleporter =
{
	local float temp;
	local vector dud;

	if ((CountDaughters("teleporter") > HOOK_OUT))
	{
		sprint(self, PRINT_HIGH, "You can have no more than two teleporters at a time\n");
		return;
	}
	makevectors(self.v_angle);
	v_forward_z = STATE_HOME;
	v_forward = normalize(v_forward);
	obj_org = (self.origin + (v_forward * FL_DIALOG));
	obj_mins = '-16 -16 -16';
	obj_maxs = VEC_HULL_MAX;
	temp = CheckArea(self);
	if ((temp == FALSE))
	{
		sprint(self, PRINT_HIGH, "You cannot build there.\n");
		return;
	}
	newmis = spawn();
	self.build_finished = (time + WEAPON_BIG);
	self.saved_time = (time + HOOK_OUT);
	self.ammo_nails = (self.ammo_nails - 50);
	self.currentammo = (self.ammo_nails - 50);
	self.th_build = Build_Teleporter;
	self.oldorigin = self.origin;
	self.build_item = newmis;
	newmis.r_owner = self;
	setorigin(newmis, obj_org);
	setmodel(newmis, "progs/portal.mdl");
	newmis.solid = SOLID_BBOX;
	newmis.takedamage = DAMAGE_YES;
	newmis.th_pain = TeleporterPain;
	newmis.health = 100;
	newmis.ammo_nails = 50;
	newmis.max_health = 100;
	newmis.movetype = MOVETYPE_TOSS;
	dud = normalize((self.origin - newmis.origin));
	newmis.angles = vectoangles(dud);
	setsize(newmis, obj_mins, obj_maxs);
	newmis.touch = SUB_Null;
	newmis.classname = "building_teleporter";
	newmis.netname = "teleporter";
	newmis.th_die = TeleporterGib;
	newmis.oldorigin = self.oldorigin;
	newmis.colormap = self.colormap;
};

void() Wizard_SetCurrentAmmo =
{
	self.items = (self.items - (self.items & (((IT_SHELLS | IT_NAILS) | IT_ROCKETS) | IT_CELLS)));
	if ((self.weapon == IT_AXE))
	{
		self.currentammo = STATE_HOME;
		self.weaponmodel = "progs/v_staff.mdl";
		self.weaponframe = STATE_HOME;
	}
	else
	{
		if ((self.weapon == IT_SHOTGUN))
		{
			self.currentammo = self.ammo_cells;
			self.weaponmodel = "progs/v_orb2.mdl";
			self.weaponframe = STATE_HOME;
			self.items = (self.items | IT_CELLS);
		}
		else
		{
			if ((self.weapon == IT_SUPER_SHOTGUN))
			{
				self.currentammo = self.ammo_nails;
				self.weaponmodel = "progs/v_cod2.mdl";
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
};

float() Wizard_BestWeapon =
{
	local float it;

	it = self.items;
	if (((self.ammo_cells >= HOOK_OUT) && (it & IT_SHOTGUN)))
	{
		return (IT_SHOTGUN);
	}
	return (IT_AXE);
};

float() Wizard_CheckNoAmmo =
{
	if ((self.currentammo > STATE_HOME))
	{
		return (TRUE);
	}
	if ((self.weapon == IT_AXE))
	{
		return (TRUE);
	}
	self.weapon = W_BestWeapon();
	W_SetCurrentAmmo();
	return (FALSE);
};
void() player_book1;

void() Wizard_Attack =
{
	local float r;

	if (!Wizard_CheckNoAmmo())
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
			player_shot1();
			self.attack_finished = (time + 1.2);
			fire_wizard_sceptar();
		}
		else
		{
			if ((self.weapon == IT_SUPER_SHOTGUN))
			{
				self.attack_finished = (time + 0.7);
				Wizard_Teleporter();
			}
		}
	}
};

void() Wizard_ChangeWeapon =
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
			if ((self.ammo_cells < HOOK_OUT))
			{
				am = HOOK_OUT;
			}
		}
		else
		{
			if ((self.impulse == MAP_TF))
			{
				fl = IT_SUPER_SHOTGUN;
				if ((self.ammo_nails < 50))
				{
					am = HOOK_OUT;
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

void() WizardCycleWeaponCommand =
{
	local float it;
	local float am;

	it = self.items;
	self.impulse = STATE_HOME;
	while (HOOK_OUT)
	{
		am = STATE_HOME;
		if ((self.weapon == IT_SUPER_SHOTGUN))
		{
			self.weapon = IT_AXE;
		}
		else
		{
			if ((self.weapon == IT_AXE))
			{
				self.weapon = IT_SHOTGUN;
				if ((self.ammo_cells < HOOK_OUT))
				{
					am = HOOK_OUT;
				}
			}
			else
			{
				if ((self.weapon == IT_SHOTGUN))
				{
					self.weapon = IT_SUPER_SHOTGUN;
					if ((self.ammo_nails < 50))
					{
						am = HOOK_OUT;
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

void() WizardCycleWeaponReverseCommand =
{
	local float it;
	local float am;

	it = self.items;
	self.impulse = STATE_HOME;
	while (HOOK_OUT)
	{
		am = STATE_HOME;
		if ((self.weapon == IT_SUPER_SHOTGUN))
		{
			self.weapon = IT_SHOTGUN;
			if ((self.ammo_cells < HOOK_OUT))
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
					self.weapon = IT_SUPER_SHOTGUN;
					if ((self.ammo_nails < 50))
					{
						am = HOOK_OUT;
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

void() WizardImpulse =
{
	if (((self.impulse >= HOOK_OUT) && (self.impulse <= WEAPON_BIG)))
	{
		Wizard_ChangeWeapon();
	}
	if ((self.impulse == TE_LAVASPLASH))
	{
		WizardCycleWeaponCommand();
	}
	if ((self.impulse == TE_BLOOD))
	{
		WizardCycleWeaponReverseCommand();
	}
	if ((self.impulse == 44))
	{
		Wizard_Teleporter();
	}
	self.impulse = STATE_HOME;
};
