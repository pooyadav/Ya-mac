configuration AlphaBootC
{
	provides interface AsyncSend as Send;
	provides interface AsyncStdControl;

	uses interface AsyncSend as SubSend;
	uses interface Resend;
	uses interface AMPacket;
	uses interface LowPowerListening;
}
implementation
{
	components AlphaBootP as Boot;
	components new VirtualizedAlarmMilli16C() as BootAlarm;
	components new StateC() as BootState;
	
	Send = Boot;
	AsyncStdControl = Boot;

	Boot.SubSend = SubSend;
	Boot.Resend = Resend;
	Boot.AMPacket = AMPacket;
	Boot.BootAlarm -> BootAlarm;
	Boot.BootState -> BootState;
	Boot.LowPowerListening = LowPowerListening;
}
