/**
 * Handles Alpha time synchronization information in incoming packets.
 *
 * @author Poonam Yadav
 */
configuration AlphaBcastReceiverC
{
	provides interface AsyncReceive as Receive;
	provides interface StdControl;
	    
	uses interface SendReceive;	
	uses interface AlphaMacTimerControl;
	uses interface State as RadioState;
	uses interface State as BcastState;
	uses interface State as UcastState;
	uses interface AsyncReceive as SubReceive;
	uses interface Alarm<TMilli, uint16_t> as LplTimer;
	uses interface Alarm<TMilli, uint16_t> as BcastTimer;
	uses interface Alarm<TMilli, uint16_t> as LplAdaptiveTimer;
	uses interface Alarm<TMilli, uint16_t> as ExplicitSyncTimer;	
	uses interface AMPacket;
}
implementation
{
	components AlphaBcastReceiverP as BcastReceiver;
	components AlphaBootC as Boot;
	components LedsC;
	Receive = BcastReceiver;
	StdControl = BcastReceiver;
	
	
	//BcastReceiver.AlphaBcastSender = AlphaBcastSender;
	BcastReceiver.RadioState = RadioState;
	BcastReceiver.BcastState = BcastState;
	BcastReceiver.UcastState = UcastState;
	BcastReceiver.SubReceive = SubReceive;
	BcastReceiver.SendReceive = SendReceive;
        BcastReceiver.LplTimer = LplTimer;
	BcastReceiver.BcastTimer = BcastTimer;
	BcastReceiver.LplAdaptiveTimer = LplAdaptiveTimer;
	BcastReceiver.ExplicitSyncTimer = ExplicitSyncTimer;
	BcastReceiver.Leds -> LedsC;

	//BcastReceiver.SendAlarm = SendAlarm;
	BcastReceiver.AMPacket = AMPacket;
	BcastReceiver.AlphaBoot -> Boot;
	BcastReceiver.AlphaMacTimerControl = AlphaMacTimerControl;
}
