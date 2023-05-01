//Decompiled code. Please respect the original copyright.

void() KnightPrecache =
{
	precache_model("progs/shield.mdl");
	precache_model("progs/v_sword.mdl");
	precache_sound("hknight/attack1.wav");
	precache_sound("knight/sword1.wav");
	precache_sound("knight/sword2.wav");
	precache_sound("knight/draw.wav");
	precache_sound("knight/bounce.wav");
	precache_model2("progs/k_spike.mdl");
	precache_model("progs/sheild.mdl");
};

void() Knight_SetSpawn =
{
	self.max_shells = STATE_HOME;
	self.max_nails = STATE_HOME;
	self.max_rockets = STATE_HOME;
	self.max_cells = 150;
	self.items = ((IT_AXE | IT_SHOTGUN) | IT_ARMOR3);
	self.armorvalue = 200;
	self.armortype = 0.8;
	self.max_type = 0.8;
	self.max_value = 400;
	self.ammo_cells = 25;
	self.max_bit = IT_ARMOR3;
	self.max_strafe = 150;
	self.max_speed = 175;
	self.pl_skin = "stc_knig";
	stuffcmd(self, "exec cfg/knight.cfg\n");
	stuffcmd(self, "alias +sheild \"impulse 198\"\n");
	stuffcmd(self, "alias -sheild \"impulse 199\"\n");
};

void(float offset) Knight_FireSpike =
{
	local vector offang;
	local vector org;
	local vector vec;

	if ((self.ammo_cells <= STATE_HOME))
	{
		return;
	}
	if ((deathmatch != WEAPON_SPIKES))
	{
		self.ammo_cells = (self.ammo_cells - 0.5);
		self.currentammo = (self.ammo_cells - 0.5);
	}
	offang = self.v_angle;
	offang_y = (offang_y + (offset * CLASS_WIZARD));
	offang_x = (offang_x * CONTENT_EMPTY);
	makevectors(offang);
	org = ((self.origin + (v_up * FL_VOTED)) + (v_forward * 20));
	vec = normalize(v_forward);
	vec_z = ((STATE_HOME - vec_z) + ((random() - 0.5) * 0.1));
	launch_spike(org, vec);
	newmis.classname = "knightspike";
	setmodel(newmis, "progs/k_spike.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	newmis.velocity = (vec * 300);
	sound(self, CHAN_WEAPON, "hknight/attack1.wav", WEAPON_SHOTGUN, ATTN_NORM);
};

void() Knight_FireSword =
{
	local vector source;
	local vector org;

	makevectors(self.v_angle);
	source = (self.origin + '0 0 16');
	traceline(source, (source + (v_forward * FL_DIALOG)), FALSE, self);
	if ((trace_fraction == WEAPON_SHOTGUN))
	{
		return;
	}
	org = (trace_endpos - (v_forward * WEAPON_SPIKES));
	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = WEAPON_SHOTGUN;
		SpawnBlood(org, 20);
		T_Damage(trace_ent, self, self, 80, STATE_HOME);
	}
	else
	{
		sound(self, CHAN_WEAPON, "player/axhit2.wav", WEAPON_SHOTGUN, ATTN_NORM);
		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte(MSG_MULTICAST, TE_GUNSHOT);
		WriteByte(MSG_MULTICAST, MAP_TF);
		WriteCoord(MSG_MULTICAST, org_x);
		WriteCoord(MSG_MULTICAST, org_y);
		WriteCoord(MSG_MULTICAST, org_z);
		multicast(org, MULTICAST_PVS);
	}
};

void() Knight_SetCurrentAmmo =
{
	self.items = (self.items - (self.items & (((IT_SHELLS | IT_NAILS) | IT_ROCKETS) | IT_CELLS)));
	if ((self.aflag & FL_SHEILD))
	{
		self.currentammo = STATE_HOME;
		self.weaponmodel = "";
		self.weaponframe = STATE_HOME;
		return;
	}
	if ((self.weapon == IT_AXE))
	{
		self.currentammo = STATE_HOME;
		self.weaponmodel = "progs/v_sword.mdl";
		self.weaponframe = STATE_HOME;
	}
	else
	{
		if ((self.weapon == IT_SHOTGUN))
		{
			self.currentammo = self.ammo_cells;
			self.weaponmodel = "progs/v_sword.mdl";
			self.weaponframe = STATE_HOME;
			self.items = (self.items | IT_CELLS);
		}
		else
		{
			self.currentammo = STATE_HOME;
			self.weaponmodel = "";
			self.weaponframe = STATE_HOME;
		}
	}
};

float() Knight_BestWeapon =
{
	local float it;

	it = self.items;
	if (((self.ammo_cells >= WEAPON_SHOTGUN) && (it & IT_SHOTGUN)))
	{
		return (IT_SHOTGUN);
	}
	return (IT_AXE);
};

float() Knight_CheckNoAmmo =
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

void() Knight_Attack =
{
	local float r;

	if (!Knight_CheckNoAmmo())
	{
		return;
	}
	makevectors(self.v_angle);
	self.show_hostile = (time + WEAPON_SHOTGUN);
	if ((self.aflag & FL_SHEILD))
	{
		return;
	}
	if ((self.weapon == IT_AXE))
	{
		self.attack_finished = (time + 0.5);
		r = random();
		if ((r < 0.25))
		{
			sound(self, CHAN_WEAPON, "knight/sword1.wav", WEAPON_SHOTGUN, ATTN_NORM);
			player_axe1();
		}
		else
		{
			if ((r < 0.5))
			{
				sound(self, CHAN_WEAPON, "knight/sword2.wav", WEAPON_SHOTGUN, ATTN_NORM);
				player_axeb1();
			}
			else
			{
				if ((r < 0.75))
				{
					sound(self, CHAN_WEAPON, "knight/sword1.wav", WEAPON_SHOTGUN, ATTN_NORM);
					player_axec1();
				}
				else
				{
					sound(self, CHAN_WEAPON, "knight/sword2.wav", WEAPON_SHOTGUN, ATTN_NORM);
					player_axed1();
				}
			}
		}
	}
	else
	{
		if ((self.weapon == IT_SHOTGUN))
		{
			self.attack_finished = (time + 0.5);
			sound(self, CHAN_WEAPON, "knight/sword2.wav", WEAPON_SHOTGUN, ATTN_NORM);
			player_ssword1();
		}
	}
};

void() Knight_ChangeWeapon =
{
	local float it;
	local float am;
	local float fl;

	it = self.items;
	am = STATE_HOME;
	if ((self.impulse == WEAPON_SHOTGUN))
	{
		fl = IT_AXE;
	}
	else
	{
		if ((self.impulse == WEAPON_ROCKET))
		{
			fl = IT_SHOTGUN;
			if ((self.ammo_cells < WEAPON_SHOTGUN))
			{
				am = WEAPON_SHOTGUN;
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

void() KnightCycleWeaponCommand =
{
	local float it;
	local float am;

	it = self.items;
	self.impulse = STATE_HOME;
	while (WEAPON_SHOTGUN)
	{
		am = STATE_HOME;
		if ((self.weapon == IT_AXE))
		{
			self.weapon = IT_SHOTGUN;
			if ((self.ammo_cells < WEAPON_SHOTGUN))
			{
				am = WEAPON_SHOTGUN;
			}
		}
		else
		{
			if ((self.weapon == IT_SHOTGUN))
			{
				self.weapon = IT_AXE;
			}
		}
		if (((self.items & self.weapon) && (am == STATE_HOME)))
		{
			W_SetCurrentAmmo();
			return;
		}
	}
};

void() KnightCycleWeaponReverseCommand =
{
	local float it;
	local float am;

	it = self.items;
	self.impulse = STATE_HOME;
	while (WEAPON_SHOTGUN)
	{
		am = STATE_HOME;
		if ((self.weapon == IT_AXE))
		{
			self.weapon = IT_SHOTGUN;
			if ((self.ammo_cells < WEAPON_SHOTGUN))
			{
				am = WEAPON_SHOTGUN;
			}
		}
		else
		{
			if ((self.weapon == IT_SHOTGUN))
			{
				self.weapon = IT_AXE;
			}
		}
		if (((it & self.weapon) && (am == STATE_HOME)))
		{
			W_SetCurrentAmmo();
			return;
		}
	}
};

void() ShieldShow =
{
	local entity missile;

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_NONE;
	missile.solid = SOLID_NOT;
	missile.angles = self.angles;
	missile.nextthink = (time + 0.001);
	missile.think = SUB_Remove;
	setmodel(missile, "progs/shield.mdl");
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(missile, (((self.origin + (v_forward * 20)) - (v_up * TE_TELEPORT)) + '0 0 16'));
};

void() KnightImpulse =
{
	if (((self.impulse >= WEAPON_SHOTGUN) && (self.impulse <= WEAPON_BIG)))
	{
		Knight_ChangeWeapon();
	}
	if ((self.impulse == TE_LAVASPLASH))
	{
		KnightCycleWeaponCommand();
	}
	if ((self.impulse == TE_BLOOD))
	{
		KnightCycleWeaponReverseCommand();
	}
	if ((self.impulse == 198))
	{
		self.weaponmodel = "";
		self.aflag = (self.aflag | FL_SHEILD);
		self.max_speed = 180;
		self.max_strafe = STATE_HOME;
		SetSpeed();
	}
	if ((self.impulse == 199))
	{
		self.aflag = (self.aflag - (self.aflag & FL_SHEILD));
		W_SetCurrentAmmo();
		self.max_speed = 150;
		self.max_strafe = 175;
		SetSpeed();
		sound(self, CHAN_WEAPON, "knight/draw.wav", WEAPON_SHOTGUN, ATTN_NORM);
	}
	if ((self.aflag == FL_SHEILD))
	{
		ShieldShow();
	}
	self.impulse = STATE_HOME;
};
