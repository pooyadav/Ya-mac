#include "AlphaBcastMsg.h"
#include "AlphaConstants.h"

/**
 * Handles Alpha time synchronization information in incoming packets.
 *
 * @author Poonam Yadav
 */
module AlphaBcastReceiverP
{
	provides interface AsyncReceive as Receive;
	provides interface Packet;
	provides interface StdControl;
	uses interface SendReceive;
	
	uses interface State as RadioState;
	uses interface State as BcastState;
	uses interface State as UcastState;
	uses interface AsyncReceive as SubReceive;
	uses interface Alarm<TMilli, uint16_t> as LplTimer;
	uses interface Alarm<TMilli, uint16_t> as BcastTimer;
	uses interface Alarm<TMilli, uint16_t> as LplAdaptiveTimer;
	uses interface Alarm<TMilli, uint16_t> as ExplicitSyncTimer;
	uses interface AMPacket;
	uses interface Packet as SubPacket;
	uses interface AsyncStdControl as AlphaBoot;
	uses interface AlphaMacTimerControl; //9June
	uses interface Leds;
}
implementation
{
	uint16_t tca_ = 0;
	uint16_t exp_syn_ = 0;	
	uint16_t ucast_dest = 0xFF;
	norace message_t * msg_;
	message_t tmpmsg;
	bool Sync = FALSE;//For keeping record that this node is synchronised or not
	uint8_t PrSyncCount = 0 , SyncCount = 0;
	uint8_t PrNeighbourCount = 0, NeighbourCount = 0;
        uint16_t tum = 0;
	int16_t Tot_diff = 0 , Max_diff = 0;
	norace int16_t diff = 0;
	
	command error_t StdControl.start()
	{
	atomic tca_ =  call AlphaMacTimerControl.getLplTimerInterval();
	atomic exp_syn_ = call AlphaMacTimerControl.getExplicitBcastTimerInterval();
	call LplTimer.start(tca_);
          }
	    
	task void updateBufferTask()
	{
	call SubReceive.updateBuffer(msg_);
	}
	
	
	
	async event void SubReceive.receive(message_t * msg, void * payload, uint8_t len)
	{		
		uint8_t offset;
		AlphaBcastMsg * bcast;
		
		atomic msg_ = msg;
			
		//call Leds.led1Toggle();
		if(call AMPacket.type(msg) == AM_REQSENDMSG)
		{	// If sendrequest message is recived, now need to see who has sent this, if the sender is intented receiver then signal event to ucast send
		 ucast_dest =  call SendReceive.getUcastDestination();
		  
		  if(call AMPacket.source(msg) == ucast_dest){
		   if(call SendReceive.ucastSendstart(ucast_dest) == SUCCESS){  }
		     
		  }
		 post updateBufferTask();
		    
		  return;
		}

		else if(call AMPacket.type(msg) == AM_ALPHASYNCMSG)
		{	// If Broadcast message received, if packet is Bcastcastsyn, extract time from the footer and update time task.
			post updateBufferTask();
		        
			offset = len - call AMPacket.headerSize() - sizeof(AlphaBcastMsg);	
			bcast = (AlphaBcastMsg *)(payload + offset);
    
			diff = (int16_t)(call BcastTimer.getAlarm() - call  BcastTimer.getNow());
			post updateBufferTask();
		      return;
		}
		else if(call AMPacket.type(msg) == AM_ALPHABCASTMSG )
		{	// If Broadcast message received, extract time and forward the packet to upper layer for further processing 
			
			offset = len - sizeof(AlphaBcastMsg);
			bcast = (AlphaBcastMsg *)(payload + offset);
			atomic diff = (int16_t)(call BcastTimer.getAlarm() - call  BcastTimer.getNow()); //Here for testing replaced bcast->time to bcast->timestamp and also in next set set of instructions
			atomic tum = call AlphaMacTimerControl.getBcastTimerInterval();
			//Tot_diff += diff;
			//if(diff > Max_diff) {Max_diff = diff;}
			NeighbourCount ++;
			//call Leds.led0Toggle(); 
///Comment start from here if need to disable Alpha Synchronicity Algorithm
		//	if(Sync == FALSE)
		//	    {   
			   //  if((PrSyncCount != 0 ) &&  (PrSyncCount >= ( PrNeighbourCount * 0.6))){ Sync = TRUE;
			//	call AlphaMacTimerControl.setSync(Sync); }
					
			// The reason why this check is inside is to make it sure that atleast one neighbour in the current phase is coming within the safe reason to assume, node is in sync area.
						
                 //             }
		 
		   if(diff < (400) || diff > (tum-400)){
			      SyncCount++;
			         }
// 	           else if( diff > (0.05 * tum ) || diff < (0.10 * tum)){  call BcastTimer.stop(); 
// 		  call  BcastTimer.start(diff-(0.05 * tum));  
// 		   }
		   else{
		     if(Sync == FALSE){
		    if(diff < tum && (diff > (400)) && (diff < (tum-400))){
			             //call Leds.led0Toggle();  
			  // if (0.04 * diff > 25 ){ //Poonam: next line commented to get 
			    call BcastTimer.stop();
			//    call Leds.led2Toggle();
			  //  call  BcastTimer.start(0.04 * diff -25); 
		        //   }
                        //   else {	
			     call  BcastTimer.start(1);
				    
				//  } 
		    }
		}}
/// Comment Ends here -------------------///
			
		   	 signal Receive.receive(msg, payload, len);
		    	 return;
	    }
	else{  	   
		    
		   if(call AMPacket.destination(msg) == TOS_NODE_ID)
		    {
		     
		    //call Leds.led1On();
		     signal Receive.receive(msg, payload, len);
		     // post updateBufferTask();
		      return;
		    }
// 		  else if(call AMPacket.destination(msg) == AM_BROADCAST_ADDR) { signal Receive.receive(msg, payload, len); return; }
		  else{
		      post updateBufferTask();
		      return;
		    }

		   }
				
	}
		
	command void Receive.updateBuffer(message_t * msg)
	{
		call SubReceive.updateBuffer(msg);
	}
	
	command void * Packet.getPayload(message_t * msg, uint8_t len)
	{
		return call Packet.getPayload(msg, len);
	}

	command void Packet.clear(message_t * msg)
	{
		call SubPacket.clear(msg);
	}

	command uint8_t Packet.payloadLength(message_t * msg)
	{
		if(call AMPacket.type(msg) == AM_ALPHABCASTMSG)
		return call SubPacket.payloadLength(msg) - sizeof(AlphaBcastMsg);
		else 
		call SubPacket.payloadLength(msg);
	}

	command void Packet.setPayloadLength(message_t * msg, uint8_t len)
	{
		if(call AMPacket.type(msg) == AM_ALPHABCASTMSG)
		call SubPacket.setPayloadLength(msg, len + sizeof(AlphaBcastMsg));
		else
		  call SubPacket.setPayloadLength(msg, len);
	}
	
	command uint8_t Packet.maxPayloadLength()
	{
		return call SubPacket.maxPayloadLength() - sizeof(AlphaBcastMsg);
	}

	async event void LplTimer.fired()
	{
	}

	async event void BcastTimer.fired()
	{
	  /// Comment start to Disable Alpha Synchronicity Algorithm
	  if(Sync == FALSE){ 
	  PrNeighbourCount = NeighbourCount;  
	  if(NeighbourCount >= 1){
	  if((SyncCount != 0 ) &&  (SyncCount >= ( NeighbourCount * 0.6))){ 
	    Sync = TRUE;
	    call AlphaMacTimerControl.setSync(Sync);                      }	  
	  } }	  
	  else{ 	  
	  if( SyncCount < (PrNeighbourCount * 0.4) ){ Sync = FALSE;
		                                      call AlphaMacTimerControl.setSync(Sync);
					// call Leds.led0Off();  (NeighbourCount == 1 && SyncCount < NeighbourCount)||
					  }
	  }	 
	  //PrSyncCount = SyncCount;
	  call AlphaMacTimerControl.setNeighbour(PrNeighbourCount);
	  call AlphaMacTimerControl.setSynTimerError(SyncCount);
	  NeighbourCount = 0;
	  SyncCount = 0;
	  Tot_diff = 0;
	  Max_diff = 0;
	   
	/// Comment end to Disable Alpha Synchronicity Algorithm
        }
	async event void LplAdaptiveTimer.fired()
	{
	}

	async event void ExplicitSyncTimer.fired()
	{
	}
	command error_t StdControl.stop()
	{ 
	}

}
