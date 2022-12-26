/**
 * A moderately lightweight actor class meant to be used as an invisible stand-in for
 * Actor-related operations, such as distance or line-of-sight checks.
**/
class Agent : Actor
{
	Default
	{
		+NOGRAVITY;
		+NOINTERACTION;
		+NODAMAGE;
		+INVULNERABLE;
		+NOSECTOR;
	}
}