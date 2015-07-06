module AlphaBootP
{
	provides interface AsyncSend as Send;
	provides interface AsyncStdControl;

	uses interface AsyncSend as SubSend;
	uses interface Resend;
	uses interface AMPacket;
	uses interface Alarm<TMilli, uint16_t> as BootAlarm;
	uses interface State as BootState;
	uses interface LowPowerListening;
}
implementation
{
	message_t boot;
	
	enum
	{
		S_IDLE = 0,
		S_BOOTING = 1,
	};
	
	void send();
	void resend();
	
	async command error_t AsyncStdControl.start()
	{
// 		if(call BootState.requestState(S_BOOTING) != SUCCESS)
// 			return EBUSY;
// 			
// 		call AMPacket.setType(&boot, AM_ALPHABOOTMSG);
// 		call AMPacket.setSource(&boot, TOS_NODE_ID);
// 		call AMPacket.setDestination(&boot, AM_BROADCAST_ADDR);
// 
// 		call BootAlarm.start(call LowPowerListening.getLocalSleepInterval() * 2);
// 		send();
		
		return SUCCESS;
	}
	
	async command error_t AsyncStdControl.stop()
	{
// 		call BootState.toIdle();
		return SUCCESS;
	}
	
	async event void BootAlarm.fired()
	{
// 		call BootState.toIdle();
	}

// 	task void doSend()
// 	{
// 		send();
// 	}
// 	
// 	void send()
// 	{
// 		if(call SubSend.send(&boot, call AMPacket.headerSize()) != SUCCESS)
// 			post doSend();
// 	}
// 	
// 	task void doResend()
// 	{
// 		resend();
// 	}
// 	
// 	void resend()
// 	{
// 		if(call Resend.resend() != SUCCESS)
// 			post doResend();
// 	}
	
	async command error_t Send.send(message_t * msg, uint8_t len)
	{
		return call SubSend.send(msg, len);
	}
	
//	task void updateBufferTask()
//	{
//		call SubSend.updateBuffer(&boot);
//	}
	
	async event void SubSend.sendDone(message_t * msg, error_t error)
	{
// 		if(msg == &boot)
// 		{
// //			post updateBufferTask();
// 			if(!call BootState.isIdle())
// 				resend();
// 		}
// 		else
			signal Send.sendDone(msg, error);
	}

	async command void * Send.getPayload(message_t * msg, uint8_t len)
	{
		return call SubSend.getPayload(msg, len);
	}
	
	async command uint8_t Send.maxPayloadLength()
	{
		return call SubSend.maxPayloadLength();
	}
	
	async command error_t Send.cancel(message_t * msg)
	{
		return call SubSend.cancel(msg);
	}
}
