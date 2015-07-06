configuration AlphaListenerC
{
	provides interface AsyncReceive as Receive;
	
	uses interface AlphaBeaconManager;
	uses interface RadioPowerControl;
	uses interface AsyncReceive as SubReceive;
	uses interface AMPacket;
}
implementation
{
	components PeriodicLplListenerC as Listener;
	components AlphaListenerFilterP as AlphaFilter, LedsC;
	
	Receive = Listener.Receive;

	Listener.AlphaBeaconManager -> AlphaFilter.AlphaBeaconManager;
	Listener.RadioPowerControl = RadioPowerControl;
	Listener.SubReceive -> AlphaFilter.Receive;
	//Listener.SendState = SendState;
	Listener.AMPacket = AMPacket;
	
	AlphaFilter.SubAlphaBeaconManager = AlphaBeaconManager;
	AlphaFilter.SubReceive = SubReceive;
	AlphaFilter.Leds -> LedsC; 
}
