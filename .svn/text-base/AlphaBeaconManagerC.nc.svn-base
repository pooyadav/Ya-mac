/**
 * Automatically performs periodic LPL checks.
 *
 * @author Poonam Yadav
 */
configuration AlphaBeaconManagerC
{
	provides interface AlphaBeaconManager;
	provides interface LowPowerListening;
	provides interface StdControl;
	provides interface AlphaMacTimerControl;

	uses interface ChannelMonitor;
// 	uses interface Alarm<TMilli, uint16_t> as LplTimer;
// 	uses interface Alarm<TMilli, uint16_t> as BcastTimer;
// 	uses interface Alarm<TMilli, uint16_t> as LplAdaptiveTimer;
// 	uses interface Alarm<TMilli, uint16_t> as ExplicitSyncTimer;
	
}
implementation
{
	components AlphaBeaconManagerP, LedsC;
	components new StateC();
	
	AlphaBeaconManager = AlphaBeaconManagerP;
	LowPowerListening = AlphaBeaconManagerP;
	StdControl = AlphaBeaconManagerP;
	AlphaMacTimerControl = AlphaBeaconManagerP;
	AlphaBeaconManagerP.ChannelMonitor = ChannelMonitor;
	AlphaBeaconManagerP.Leds -> LedsC;
	AlphaBeaconManagerP.State -> StateC;
}
