/**
 * Provides the ALPHA-MAC layer.
 *
 * @author Poonam Yadav
 */
configuration MacC
{
        provides interface AsyncReceive as Receive;
        provides interface AsyncSend as Send;
	provides interface SplitControl;
	provides interface CcaControl[am_id_t amId];
	provides interface AlphaMacTimerControl;
	
	uses interface RadioPowerControl;
	uses interface ChannelMonitor;
      	uses interface AsyncReceive as SubReceive;
	uses interface AsyncSend as SubSend;
	uses interface Resend;
	uses interface PacketAcknowledgements; //poonam need to check it
	uses interface AMPacket;
	uses interface CcaControl as SubCcaControl[am_id_t amId]; //Poonam Need to see is boot c require it or not?

}
implementation
{
	components MacControlC as Control;
	components AlphaBcastSenderC as BcastSender, AlphaBcastReceiverC as BcastReceiver;
	components AlphaSenderC as Sender, AlphaListenerC as Listener;
	components AlphaSplitControlC;
	components AlphaBeaconManagerC as BManager;
	components new StateC() as BcastState;
	components new StateC() as UcastState;
	components new StateC() as RadioState;
	components new StateC() as UcastReqState;
	
	components new VirtualizedAlarmMilli16C() as BcastTimer; //poonam 8th June
	components new VirtualizedAlarmMilli16C() as LplTimer; //poonam 8th June
	components new VirtualizedAlarmMilli16C() as LplAdaptiveTimer; // poonam 8th June
	components new VirtualizedAlarmMilli16C() as ExplicitBcastTimer; //poonam 8th June
	
	Receive = Listener;
	Send = Sender;
	SplitControl = AlphaSplitControlC;
	AlphaMacTimerControl = BManager;
	CcaControl = SubCcaControl;
	Control.SubLpl -> BManager;
	Control.SubMacControlParameters -> BManager;
	Control.SubAlphaTest -> BcastSender;
	
	Sender.UcastSend  -> BcastSender.UcastSend;
	Sender.BcastSend -> BcastSender.BcastSend;
	//Sender.BcastSend = SubSend;
	Sender.AMPacket = AMPacket;
	Sender.PacketAcknowledgements = PacketAcknowledgements; //poonam just keeping it to make macC compatible with upper layers
	Sender.SubCcaControl = SubCcaControl;//poonam just keeping it to make macC compatible with upper layers
				
	Listener.AlphaBeaconManager -> BManager;
	Listener.RadioPowerControl = RadioPowerControl;
	Listener.SubReceive -> BcastReceiver.Receive;
	Listener.AMPacket = AMPacket;
	
	BManager.ChannelMonitor = ChannelMonitor;
		
	BcastSender.SubSend = SubSend;
	BcastSender.Resend = Resend;
	BcastSender.AMPacket = AMPacket;
        BcastSender.RadioPowerControl = RadioPowerControl;
	BcastSender.LplTimer -> LplTimer;
        BcastSender.BcastTimer -> BcastTimer; //poonam 8June
	BcastSender.LplAdaptiveTimer -> LplAdaptiveTimer; //poonam 8June
	BcastSender.ExplicitSyncTimer -> ExplicitBcastTimer; //poonam 9 june
	BcastSender.AlphaMacTimerControl -> BManager; //poonam 9 June
	BcastSender.RadioState->RadioState;
	BcastSender.UcastState->UcastState;
	BcastSender.BcastState->BcastState;
	BcastSender.UcastReqState->UcastReqState;
	 

	BcastReceiver.SendReceive -> BcastSender.SendReceive;
	BcastReceiver.RadioState -> RadioState;
	BcastReceiver.BcastState -> BcastState;
	BcastReceiver.UcastState -> UcastState;	
	BcastReceiver.SubReceive = SubReceive;
	BcastReceiver.AMPacket = AMPacket;
	BcastReceiver.LplTimer-> LplTimer; //poonam 8June
	BcastReceiver.BcastTimer -> BcastTimer; //poonam 8June
	BcastReceiver.LplAdaptiveTimer -> LplAdaptiveTimer; //poonam 8June
	BcastReceiver.ExplicitSyncTimer -> ExplicitBcastTimer; //poonam 9th june
	BcastReceiver.AlphaMacTimerControl -> BManager; //poonam 9June
	
	AlphaSplitControlC.RadioPowerControl = RadioPowerControl;
	AlphaSplitControlC.RadioState -> RadioState;
	AlphaSplitControlC.BeaconManagerControl -> BManager;
	AlphaSplitControlC.BcastControl -> BcastSender;
}
