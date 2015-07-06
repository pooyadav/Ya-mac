#include "AlphaConstants.h"

/**
 * Sends packets with prefixed preambles, according to the Alpha-MAC
 * protocol.
 *
 * @author Poonam Yadav
 */
module AlphaSenderP
{
	provides interface AsyncSend as Send;
	provides interface CcaControl[am_id_t amId];

	uses interface AsyncSend as UcastSend;
	uses interface AsyncSend as BcastSend;
	uses interface AMPacket;
	uses interface PacketAcknowledgements;
	uses interface CcaControl as SubCcaControl[am_id_t amId];
	uses interface Leds;
	
}
implementation
{   	

	async command error_t Send.send(message_t * msg, uint8_t len)
	{
	  // call Leds.led0On();
	 //  call Leds.led1Toggle();
	  //  Poonam :Attention , Need to separate out the logic of differentiating the Bcast and Ucast packets
	  if(call AMPacket.destination(msg) == AM_BROADCAST_ADDR ){   //We are differntiating packet on the basis of the destinations:
	  //call Leds.led0On();
	  if(call BcastSend.send(msg, len) == SUCCESS){
	    // call Leds.led0On();
	     return SUCCESS;
	   }
	    }
	  else {
        if(call UcastSend.send(msg, len) == SUCCESS){return SUCCESS; }
	
	   }
	  
	    return SUCCESS;
	}
	
	
	async event void UcastSend.sendDone(message_t * msg, error_t error)
	{
	     signal Send.sendDone(msg, error);		
	}
      
   async event void BcastSend.sendDone(message_t * msg, error_t error)
	{    
	     signal Send.sendDone(msg, error);	
	     
	}
	
		
	async command error_t Send.cancel(message_t * msg)
	{
	   if(call AMPacket.destination(msg) == AM_BROADCAST_ADDR ){ 
	    call BcastSend.cancel(msg);
	    }
	  else {call UcastSend.cancel(msg);}
		return SUCCESS;
		
	}
	
	async command uint8_t Send.maxPayloadLength()
	{
		return call BcastSend.maxPayloadLength();
	}
	
	async command void * Send.getPayload(message_t * msg, uint8_t len)
	{
		return call UcastSend.getPayload(msg, len);
	}
	


async event uint16_t SubCcaControl.getInitialBackoff[am_id_t amId](message_t *
		msg, uint16_t defaultBackoff)
	{
		
	    return signal CcaControl.getInitialBackoff[amId](msg, defaultBackoff);
		
	}
	
	default async event uint16_t CcaControl.getInitialBackoff[am_id_t amId](message_t *
		msg, uint16_t defaultBackoff)
	{
		return defaultBackoff;
	}

	async event uint16_t SubCcaControl.getCongestionBackoff[am_id_t amId](message_t *
		msg, uint16_t defaultBackoff)
	{
		return signal CcaControl.getCongestionBackoff[amId](msg, defaultBackoff);
	}
	
	default async event uint16_t CcaControl.getCongestionBackoff[am_id_t amId](message_t *
		msg, uint16_t defaultBackoff)
	{
		return defaultBackoff;
	}
	
	async event bool SubCcaControl.getCca[am_id_t amId](message_t * msg, bool
		defaultCca)
	{
		return signal CcaControl.getCca[amId](msg, defaultCca);
	}

	default async event bool CcaControl.getCca[am_id_t amId](message_t * msg,
		bool defaultCca)
	{
		return defaultCca;
	}

      
}
