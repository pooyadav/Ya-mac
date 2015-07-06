configuration AlphaSenderC
{
	provides interface AsyncSend as Send;
	
	uses interface AsyncSend as UcastSend;
	uses interface AsyncSend as BcastSend;
	uses interface AMPacket;
	uses interface PacketAcknowledgements; //just included to keep compatible with upper layers
	uses interface CcaControl as SubCcaControl[am_id_t amId]; //just included to keep compatible with upper layers
	
}
implementation
{
	components AlphaSenderP;
	components LedsC;
	Send = AlphaSenderP;
		
	AlphaSenderP.AMPacket = AMPacket;
	AlphaSenderP.BcastSend = BcastSend;//poonam-Need Attention
	AlphaSenderP.UcastSend = UcastSend;  //poonam 
	AlphaSenderP.PacketAcknowledgements = PacketAcknowledgements;
	AlphaSenderP.SubCcaControl = SubCcaControl;
	AlphaSenderP.Leds -> LedsC;
}
