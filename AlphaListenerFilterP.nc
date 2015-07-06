module AlphaListenerFilterP
{
	provides interface AlphaBeaconManager;
	provides interface AsyncReceive as Receive;
	
	uses interface AlphaBeaconManager as SubAlphaBeaconManager;
	//uses interface State as SendState;
	uses interface AsyncReceive as SubReceive;
	uses interface Leds;
}
implementation
{
	uint16_t packetCount = 0;
	
	async event void SubAlphaBeaconManager.activityDetected(bool detected)
	{
		uint16_t lastCount;
		atomic
		{
			lastCount = packetCount;
			packetCount = 0;
		}
		
		signal AlphaBeaconManager.activityDetected(detected ||
			(lastCount > 0)	);    //Poonam this require serious concern, need to fix it up
	}
	
	command void Receive.updateBuffer(message_t * msg)
	{
		call SubReceive.updateBuffer(msg);
	}

	async event void SubReceive.receive(message_t * msg, void * payload, uint8_t len)
	{
		atomic packetCount++;
		//call Leds.led0Toggle();
		signal Receive.receive(msg, payload, len);
	}
}
