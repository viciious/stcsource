//Decompiled code. Please respect the original copyright.

string(float t) NameForClassFriend =
{
	if ((t == CLASS_OBSERVER))
	{
		return ("friendly observer\n");
	}
	if ((t == CLASS_ARCHER))
	{
		return ("friendly archer\n");
	}
	if ((t == CLASS_ALCH))
	{
		return ("friendly alchemist\n");
	}
	if ((t == CLASS_BARREL))
	{
		return ("friendly barrel man\n");
	}
	if ((t == CLASS_THIEF))
	{
		return ("friendly thief\n");
	}
	if ((t == CLASS_WIZARD))
	{
		return ("friendly wizard\n");
	}
	if ((t == CLASS_KNIGHT))
	{
		return ("friendly knight\n");
	}
	if ((t == CLASS_BSMITH))
	{
		return ("friendly blacksmith\n");
	}
};

string(float t) NameForClassEnemy =
{
	if ((t == CLASS_OBSERVER))
	{
		return ("enemy observer\n");
	}
	if ((t == CLASS_ARCHER))
	{
		return ("enemy archer\n");
	}
	if ((t == CLASS_ALCH))
	{
		return ("enemy alchemist\n");
	}
	if ((t == CLASS_BARREL))
	{
		return ("enemy barrel man\n");
	}
	if ((t == CLASS_THIEF))
	{
		return ("enemy thief\n");
	}
	if ((t == CLASS_WIZARD))
	{
		return ("enemy wizard\n");
	}
	if ((t == CLASS_KNIGHT))
	{
		return ("enemy knight\n");
	}
	if ((t == CLASS_BSMITH))
	{
		return ("enemy blacksmith\n");
	}
};

void() IdPlayer =
{
	local string suffix;
	local string name;
	local vector org;

	org = (self.origin + '0 0 16');
	traceline(org, (org + (v_forward * 2800)), FALSE, self);
	if (((trace_fraction == HOOK_OUT) || (trace_ent == world)))
	{
		return;
	}
	if ((trace_ent.item_class == "daughter"))
	{
		if ((trace_ent.r_owner == self))
		{
			name = "Your";
			suffix = " ";
		}
		else
		{
			name = trace_ent.r_owner.netname;
			if (((trace_ent.vteam == self.vteam) && MAX_TEAMS))
			{
				suffix = "'s (friendly)\n";
			}
			else
			{
				suffix = "'s (enemy)\n";
			}
		}
	}
	else
	{
		if ((trace_ent.classname == "player"))
		{
			if (((trace_ent.vteam == self.vteam) && MAX_TEAMS))
			{
				name = NameForClassFriend(trace_ent.class);
			}
			else
			{
				if ((trace_ent.class == CLASS_THIEF))
				{
					if ((trace_ent.invisible_finished >= (time + MAP_TF)))
					{
						return;
					}
				}
				name = NameForClassEnemy(trace_ent.class);
			}
			suffix = "\n";
		}
		else
		{
			return;
		}
	}
	centerprint3(self, name, suffix, trace_ent.netname);
};

void(string snd, entity who) HelpEffect =
{
	local vector org;

	org = self.origin;
	stuffcmd(who, snd);
	msg_entity = who;
	WriteByte(MSG_ONE, SVC_MUZZLEFLASH);
	WriteEntity(MSG_ONE, who);
	msg_entity = who;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_TELEPORT);
	WriteCoord(MSG_ONE, org_x);
	WriteCoord(MSG_ONE, org_y);
	WriteCoord(MSG_ONE, org_z);
};

void() SayHelp =
{
	local entity head;
	local float r;
	local string snd;

	r = random();
	if ((r < 0.5))
	{
		snd = "play misc/help1\n";
	}
	else
	{
		snd = "play misc/help2\n";
	}
	HelpEffect(snd, self);
	head = findradius(self.origin, 400);
	while (head)
	{
		if ((head.classname == "player"))
		{
			if ((head.class == CLASS_ALCH))
			{
				if ((head.vteam == self.vteam))
				{
					if ((self != head))
					{
						HelpEffect(snd, head);
					}
				}
			}
		}
		head = head.chain;
	}
};

void() Abort_Build =
{
	local entity fern;

	if ((self.build_item == world))
	{
		return;
	}
	fern = self.build_item;
	self.ammo_nails = (self.ammo_nails + fern.ammo_nails);
	self.ammo_cells = (self.ammo_cells + fern.ammo_cells);
	self.ammo_rockets = (self.ammo_rockets + fern.ammo_rockets);
	self.ammo_shells = (self.ammo_shells + fern.ammo_shells);
	fern = self;
	self = self.build_item;
	self.th_die();
	self = fern;
	sprint(self, PRINT_HIGH, "You stop building.\n");
};

void() DestroyIt =
{
	local entity hok;

	if ((self.destroy == self))
	{
		Destroy_Daughters();
		return;
	}
	hok = self;
	self = self.destroy;
	self.th_die();
	self = hok;
};

void() DestroyCommand =
{
	local entity oself;
	local vector org;

	org = (self.origin + '0 0 16');
	self.destroy = world;
	traceline(org, (org + (v_forward * 2800)), FALSE, self);
	if ((trace_fraction == HOOK_OUT))
	{
		return;
	}
	if ((trace_ent == world))
	{
		self.destroy = self;
		DestroyDialog("all your buildings");
	}
	if (((trace_ent.item_class == "daughter") && (trace_ent.r_owner == self)))
	{
		self.destroy = trace_ent;
		DestroyDialog(trace_ent.netname);
	}
};
