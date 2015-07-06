/**
 * Stamps outgoing packets with Alpha time synchronization information.
 *
 * @author Poonam Yadav
 */
configuration AlphaBcastSenderC
{
	provides interface AsyncSend as BcastSend;
        provides interface AsyncSend as UcastSend;
	provides interface StdControl;
	provides interface SendReceive;
	provides interface AlphaTest;
	
	uses interface AsyncSend as SubSend;
	uses interface AMPacket;
	uses interface Alarm<TMilli, uint16_t> as LplTimer;
	uses interface Alarm<TMilli, uint16_t> as BcastTimer;
	uses interface Alarm<TMilli, uint16_t> as LplAdaptiveTimer;
	uses interface Alarm<TMilli, uint16_t> as ExplicitSyncTimer;
        uses interface RadioPowerControl; //Poonam Attention
	uses interface Resend;
	uses interface AlphaMacTimerControl;
	uses interface State as RadioState;
	uses interface State as BcastState;
	uses interface State as UcastState;
	uses interface State as UcastReqState;
	
}
implementation
{
	components AlphaBcastSenderP as BcastSender;
	components LedsC;
	components new VirtualizedAlarmMilli16C() as BcastActiveAlarm;
	components new VirtualizedAlarmMilli16C() as BcastOffAlarm;
	components new VirtualizedAlarmMilli16C() as BcastDoneSignalTimer;
	components new VirtualizedAlarmMilli16C() as WakeupAlarm;
	components new TimerMilliC() as DutyCycleCalculator;
	BcastSend = BcastSender.BcastSend;
	UcastSend = BcastSender.UcastSend;
	StdControl = BcastSender;
	SendReceive = BcastSender.SendReceive;
	AlphaTest = BcastSender;
			
	BcastSender.SubSend = SubSend;
	BcastSender.Leds -> LedsC;
	BcastSender.AMPacket = AMPacket;
	BcastSender.RadioPowerControl = RadioPowerControl;
	BcastSender.Resend = Resend;
	BcastSender.LplTimer = LplTimer;
	BcastSender.BcastTimer = BcastTimer;
	BcastSender.LplAdaptiveTimer = LplAdaptiveTimer;
	BcastSender.AlphaMacTimerControl = AlphaMacTimerControl;
	BcastSender.ExplicitSyncTimer = ExplicitSyncTimer;
	BcastSender.BcastActiveTimer -> BcastActiveAlarm;
	BcastSender.BcastOffTimer -> BcastOffAlarm;
	BcastSender.BcastDoneSignalTimer -> BcastDoneSignalTimer;
	BcastSender.RadioState = RadioState;
	BcastSender.BcastState = BcastState;
	BcastSender.UcastState = UcastState;
	BcastSender.UcastReqState = UcastReqState;
	BcastSender.DutyCycleCalculator -> DutyCycleCalculator;
	BcastSender.WakeupAlarm -> WakeupAlarm;
	 //Poonam : Required for interaction between sender and receiver
	
}
