version "4.10.0"

const MAX_FORWARD_MOVE = 12800;
const MAX_SIDE_MOVE = 10240;

enum BobbingExt
{
	Bob_FigureEight = Bob_InverseSmooth + 1,
	Bob_Snap
}
struct Settings
{
	enum Values { OFF, VERY_LOW, LOW, MEDIUM, HIGH, VERY_HIGH, ULTRA }
}

// MUtil
#include "MUtil/MUtilLib/zscript.zs"

// Miscellaneous
#include "zscript/misc/footsteps.zs"
#include "zscript/misc/hura.zs"
#include "zscript/misc/projectileext.zs"
#include "zscript/misc/visualfx.zs"

// Weapons
#include "zscript/weapons/baseweapon.zs"
#include "zscript/weapons/colt.zs"
#include "zscript/weapons/revolver.zs"
#include "zscript/weapons/hatchet.zs"
#include "zscript/weapons/ithaca.zs"
#include "zscript/weapons/m2c.zs"
#include "zscript/weapons/dynamite.zs"
#include "zscript/weapons/sniper.zs"

// UI
#include "zscript/ui/kergstatusbar.zs"
#include "zscript/ui/baseweaponhud.zs"
#include "zscript/ui/colthud.zs"
#include "zscript/ui/revolverhud.zs"
#include "zscript/ui/ithacahud.zs"
#include "zscript/ui/m2chud.zs"
#include "zscript/ui/ishaporehud.zs"

// Weather
#include "zscript/weather/weathereffects.zs"
#include "zscript/weather/weatherhandler.zs"
#include "zscript/weather/weatherspawner.zs"
#include "zscript/weather/weatherparticlespawner.zs"
#include "zscript/weather/rainspawner.zs"

// Audio
#include "zscript/audio/ambiencehandler.zs"

#include "zscript/kergplayer.zs"

// Second-level includes.
#include "zscript_nashgore.zs"

//NPCs

//Hostile NPCs
#include "zscript/npcs/hostile/grarg.zs"
#include "zscript/npcs/hostile/lesco.zs"
#include "zscript/npcs/hostile/wyvern.zs"
#include "zscript/npcs/hostile/dryad.zs"

//Neutral/Friendly NPCs
#include "zscript/npcs/friendly/sheep.zs"
#include "zscript/npcs/friendly/penguin.zs"
#include "zscript/npcs/friendly/caribou.zs"