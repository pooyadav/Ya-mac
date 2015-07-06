#include "AlphaBcastMsg.h"
#include "AlphaConstants.h"

/**
 * Stamps outgoing packets with Alpha time synchronization information.
 *
 * @author Poonam Yadav
 */
module AlphaBcastSenderP
{
	provides interface AsyncSend as BcastSend;
	provides interface AsyncSend as UcastSend;
	provides interface StdControl;
	provides interface SendReceive;
	provides interface AlphaTest;

	uses interface AsyncSend as SubSend;
	uses interface Leds;
	uses interface AMPacket;
	uses interface RadioPowerControl; //Poonam Attention
	uses interface Resend;
	uses interface AlphaMacTimerControl;
	uses interface State as RadioState;
	uses interface State as BcastState;
	uses interface State as UcastState;
	uses interface State as UcastReqState;
	
	uses interface Alarm<TMilli, uint16_t> as LplTimer;//Alarm to keep the the tca interval
	uses interface Alarm<TMilli, uint16_t> as BcastTimer; //Alarm to maintain the TUM timer poonam 8June
	uses interface Alarm<TMilli, uint16_t> as LplAdaptiveTimer; //Alarm to keep the record the Tca time active period poonam 8June
	uses interface Alarm<TMilli, uint16_t> as ExplicitSyncTimer; //Alarm to keep the timer for the explicit syn timer
	uses interface Alarm<TMilli, uint16_t> as BcastActiveTimer; // This interface is used to keep the alarm for the active period of the radio once the TUM or BcastTimer fires.
	uses interface Alarm<TMilli, uint16_t> as BcastOffTimer;
	uses interface Alarm<TMilli, uint16_t> as BcastDoneSignalTimer;
        uses interface Timer<TMilli> as DutyCycleCalculator;
	uses interface Alarm<TMilli, uint16_t> as WakeupAlarm;
}
implementation
{  
	uint16_t ms_ = 0;
	uint16_t tum_ = 0;
	uint16_t tca_on_ = 0;
	uint16_t tca_ = 0;
	uint16_t tracer = 0;
	int16_t Max_diff_ = 0;
	uint16_t bversion = 0;
	norace uint16_t ucast_dest = 0;
	norace uint16_t bmsg_data_length, umsg_data_length, tmp_len;
	norace message_t *bcast_ = NULL;
	norace message_t *ucast_ = NULL;
	norace message_t * msgptr = NULL;
	message_t bcast, bsync, breq, tmpmsg, msg_test;
	norace bool la_running_ = FALSE; //LplAdaptivetimer running
	norace bool ba_running_ = FALSE; //BcastActivetimer running
	bool empty = TRUE;
	bool Sync = FALSE;
	norace bool BcastPending = FALSE; 
	norace bool UcastPending = FALSE;
	norace bool LocalSendBusy = FALSE;
	norace bool BreqPending = FALSE;
	norace bool BcastSendBusy = FALSE;
        void RadioStateStart();
        void RadioStateStop();
	norace bool ucastDestLocked = FALSE;
	norace uint8_t UsendTrialLimit = 0;
	norace uint8_t ReqSendTrialLimit = 0;
	uint16_t ReceiverWakeupDelay = 0;
	uint16_t PreviousDest = 0xFF;
      
	norace uint32_t radioOnTime = 0, radioCycleTime = 0, preradioOnTime = 0;
	norace uint32_t radioStartTime = 0, radioStopTime = 0;
	norace uint32_t cycleStartTime = 0, cycleEndtime = 0;
	norace uint16_t radioToggleCount = 0, DutyCycle = 0;
	norace uint32_t radioStartTimer = 0, radioStopTimer = 0;
	
	
	 
	 
	void addBcastFooter(message_t * msg, uint8_t payloadlen)
	{    	uint16_t timeLeft = 1;
		uint16_t now = 1;
		uint16_t neighbour = 0;

		AlphaBcastMsg * BcastMsg = (AlphaBcastMsg *)(call SubSend.getPayload(msg, payloadlen + sizeof(AlphaBcastMsg)) + payloadlen);
		// Point to the sync message at the end of the payload
		if((call BcastTimer.isRunning()) == TRUE){
		Max_diff_ = call AlphaMacTimerControl.getSynTimerError(); 
		neighbour = call AlphaMacTimerControl.getNeighbour();
		Sync = call AlphaMacTimerControl.getSync();
		timeLeft = call BcastTimer.getAlarm();
		now = call BcastTimer.getNow();
		 atomic{
		 BcastMsg->Sync = Sync;
		 BcastMsg->bversion = bversion + 1;
		// BcastMsg->Sync_error =(uint16_t)(tca_) ;
		// BcastMsg->neighbour=(uint16_t)(tca_on_);
		 BcastMsg->Sync_error =(uint16_t)(Max_diff_) ;
		 BcastMsg->neighbour=(uint16_t)neighbour;
                
      		}}
		/*else { 
		    atomic{
			  BcastMsg->time = (uint16_t)(tum_);
			  }
			  BcastMsg->timetemp = (uint16_t)(tum_);
		    }	*/	    
		 bversion = bversion + 1;
		}


task void signalfunction() { 
             signal BcastSend.sendDone(bcast_, SUCCESS);
      }

async event void BcastDoneSignalTimer.fired(){ 
//if(BcastPending){
		if(post signalfunction() != SUCCESS){post signalfunction();}
//}
}


task void TaskRadioStateStart() { RadioStateStart(); }   

task void TaskRadioStateStop() { RadioStateStop(); }  

void RadioStateStart()
    { int localstate;
      localstate = call RadioState.getState();
      if(localstate == R_STARTING || localstate == R_STOPPING ){
	post TaskRadioStateStart();
	}
      else if(localstate == R_OFF)
      { call RadioPowerControl.start();
        call RadioState.forceState(R_STARTING);
	//post TaskRadioStateStart();
      }
      else if(localstate == R_ON){ //We are here only if Radio is already ON
	  }
       }

void RadioStateStop()
{     int localstate;
      localstate = call RadioState.getState();
      
      if((call UcastReqState.getState() == U_REQ_ON) || (call BcastState.getState() == B_ON) || (call UcastState.getState() == U_ON))
      {	//
	
      }
      else {
	if(localstate == R_STARTING || localstate == R_STOPPING ){
	post TaskRadioStateStop();
	}
	else if(localstate == R_ON)
      {	
        call RadioPowerControl.stop();
        call RadioState.forceState(R_STOPPING);
	//call Leds.led0Off();
	
      }
      else{ call RadioPowerControl.stop();
	    //call Leds.led0Off();
	    //We are here only if Radio is already OFF
	  }

	   
	 //   call Leds.led0On();
	    //We decided not to stop because either Ucast or Bcast is in active state
	    }
 }
    
task void StartUcastSend()
	  { 
	    if(call RadioState.getState()!= R_ON){ RadioStateStart(); post  StartUcastSend(); }
	    else{
	    if(LocalSendBusy== FALSE && call RadioState.getState() == R_ON){
	  if(call SubSend.send(ucast_ , umsg_data_length) == SUCCESS){
	     atomic LocalSendBusy = TRUE; 
	     atomic UsendTrialLimit = 0; 
	    // call Leds.led2On();
	   // call Leds.led0On();
	     
	   	   	          	  }
	  else{  if(UsendTrialLimit < 3) { post StartUcastSend(); UsendTrialLimit = UsendTrialLimit + 1 ; }
		 else{
		 signal UcastSend.sendDone(ucast_, FAIL);
		 call UcastState.forceState(U_OFF);
		 RadioStateStop();
		// call Leds.led0Off();
		 UcastPending = FALSE;
		 call SendReceive.resetUcastDestination(); 
		 atomic UsendTrialLimit = 0;     
		    }}
  	   }
	  else{ if(UsendTrialLimit < 3) { post StartUcastSend(); UsendTrialLimit = UsendTrialLimit + 1 ; }
		else{
		signal UcastSend.sendDone(ucast_, FAIL);
		call UcastState.forceState(U_OFF);
		RadioStateStop();
		//call Leds.led0Off();
		UcastPending = FALSE;
		call SendReceive.resetUcastDestination();  
		atomic UsendTrialLimit = 0; 
	  } }
	  } }

    

    async command error_t BcastSend.send(message_t * msg, uint8_t len1)
	{ 	
		if (BcastPending ){  return EBUSY;}
		else if (BcastSendBusy){  return EBUSY;}
		else{ 
		atomic BcastPending = TRUE;
		memcpy(&tmpmsg, msg, sizeof(message_t) );
	        atomic tmp_len= len1;
		atomic bcast_ = msg;
		 
		call BcastDoneSignalTimer.start(2);
		//call Leds.led0On();
		return SUCCESS;
		}
	}

	async command void * BcastSend.getPayload(message_t * msg, uint8_t len)
	{
		return call SubSend.getPayload(msg, len);
	}
	
	async command error_t BcastSend.cancel(message_t * msg)
	{
		return call SubSend.cancel(msg);
	}

	async command uint8_t BcastSend.maxPayloadLength()
	{
		return call SubSend.maxPayloadLength() - sizeof(AlphaBcastMsg);
	}
	
	task void sendSyncMsg()  //Poonam Attention:Need to reimplement it because it is not inclluding the time information
	{
		call AMPacket.setType(&bsync, AM_ALPHASYNCMSG);
		call AMPacket.setSource(&bsync, TOS_NODE_ID);
		call AMPacket.setDestination(&bsync, AM_BROADCAST_ADDR);
		addBcastFooter(&bsync, 0);
		//(&bsync, call AMPacket.headerSize() + sizeof(AlphaBcastMsg));
		
	}
	
	task void createReqSend()  //Poonam Attention:Need to reimplement it because it is not inclluding the time information
	{	atomic tca_ = call AlphaMacTimerControl.getLplTimerInterval();	
		atomic tca_on_ = call AlphaMacTimerControl.getLplAdaptiveTimerInterval();
		if(tca_on_ > 0 && tca_ > 0){
		if((call RadioState.getState()!= R_ON ) && (call RadioState.getState()!= R_STARTING )){ RadioStateStart();
				                       post createReqSend();	  
				}
		else{
		call AMPacket.setType(&breq, AM_REQSENDMSG);
		call AMPacket.setSource(&breq, TOS_NODE_ID);
		call AMPacket.setDestination(&breq, AM_BROADCAST_ADDR);
		
		if(call RadioState.getState()== R_ON  && !(LocalSendBusy)){ 
		if (call SubSend.send(&breq, call AMPacket.headerSize()) == SUCCESS){  atomic LocalSendBusy = TRUE;
		 atomic ReqSendTrialLimit = 0;
		// call Leds.led2On();
		 call LplAdaptiveTimer.start(tca_on_);
				       }
	         else {if(ReqSendTrialLimit < 10) { post createReqSend(); atomic ReqSendTrialLimit = ReqSendTrialLimit + 1 ; }
		  else{ call UcastReqState.forceState(U_REQ_OFF);
			BreqPending = FALSE;
			atomic ReqSendTrialLimit = 0;
			RadioStateStop();
		  } 
		} }
		  else {if(ReqSendTrialLimit < 10) { post createReqSend(); atomic ReqSendTrialLimit = ReqSendTrialLimit + 1 ; }
		  else{	call UcastReqState.forceState(U_REQ_OFF);
			BreqPending = FALSE; 
		        atomic ReqSendTrialLimit = 0;
			RadioStateStop();
		 }  }
		}}
		else {BreqPending = FALSE; call UcastReqState.forceState(U_REQ_OFF); RadioStateStop();}
	}

///Poonam: For only unicast traffic  comment  the Sync Condition
	task void RestartBcast()
	{	atomic tum_ = call AlphaMacTimerControl.getBcastTimerInterval();
		if(tum_ > 0){	
		  call BcastTimer.start(tum_); //[Poonam: lower code commented to just make node to broadcast messages withoust switching off
		if(call AlphaMacTimerControl.getSync() == TRUE)
		{
		//call Leds.led2On();	
		call BcastOffTimer.start((tum_-400)); //Theoritically it is (1-epsilon) * TUM it is 0.97
		call BcastActiveTimer.start(400); //Theoritically it is SETW * TUM 0.03*3
		}}
		else { //call Leds.led2Off();  
 	 	      }
	}

	task void SendBcastSync(){  
	if(call RadioState.getState() == R_ON){
	atomic BcastSendBusy = TRUE;
	call BcastState.forceState(B_ON);  
	call AMPacket.setType(&tmpmsg, AM_ALPHABCASTMSG);
	call AMPacket.setSource(&tmpmsg, TOS_NODE_ID);
	call AMPacket.setDestination(&tmpmsg, AM_BROADCAST_ADDR);
	atomic addBcastFooter(&tmpmsg, tmp_len);
	
	if(!(LocalSendBusy) ){	 
	if (call SubSend.send(&tmpmsg, tmp_len + sizeof(AlphaBcastMsg)) == SUCCESS){  atomic LocalSendBusy = TRUE;
	//call Leds.led0On(); //poonam
			     }
	else{ 
	  atomic BcastSendBusy = FALSE;	
	 // atomic BcastPending = FALSE;
	 	 // post SendBcastSync();
	}
	  }
	else{ 	
	  atomic BcastSendBusy = FALSE;	
	//  atomic BcastPending = FALSE;
	 // post SendBcastSync();
	}
	}
	else{
	//atomic BcastSendBusy = FALSE;
	//atomic BcastPending = FALSE;
	//RadioStateStart();SendBcastSync
	//post SendBcastSync();
	   }
	}

	async event void BcastTimer.fired()
		{  	
		  if( post RestartBcast() != SUCCESS){ post RestartBcast(); }
		// call Leds.led1On();
		// if(BcastPending == TRUE){  //commentted to enable the independent mac layer packet exchanges specially during the synchronisation phase	
		
		// if(BcastSendBusy == FALSE){
		 if(call RadioState.getState() != R_ON){ RadioStateStart();}
		 if ( post SendBcastSync() != SUCCESS){ post SendBcastSync(); } 
		// call Leds.led1Off();  
		//}
		//}
		
	}

	task void UnicastListenOver()
        { call UcastReqState.forceState(U_REQ_OFF);
	  RadioStateStop();
	 // call Leds.led2Off();
	//  call RadioPowerControl.stop();
	//  call RadioState.forceState(R_STOPPING);
	  
	}

        async event void LplAdaptiveTimer.fired() { 
	if(post UnicastListenOver() != SUCCESS){ 
	  post UnicastListenOver(); 
	  }
        } 

	async event void BcastActiveTimer.fired() { 
	call BcastState.forceState(B_OFF);
	
	RadioStateStop();
	}

	async event void BcastOffTimer.fired() { 
	
	call BcastState.forceState(B_ON);
	RadioStateStart();
	}


	async event void SubSend.sendDone(message_t * msg, error_t err)
	{		
			atomic LocalSendBusy = FALSE;
			
			if(msg == &breq){
			atomic BreqPending = FALSE;
			}
			else if(call AMPacket.type(msg) == AM_ALPHABCASTMSG )
			{ //call Leds.led1Off();
			   atomic BcastPending = FALSE;
			   atomic BcastSendBusy = FALSE;
			 // signal BcastSend.sendDone(msg, err);
			//  call Leds.led0Off(); poonam
			}
			else{
 			signal UcastSend.sendDone(msg, err);
			call UcastState.forceState(U_OFF);
			call RadioPowerControl.stop();
			call RadioState.forceState(R_STOPPING);
			//call Leds.led2Off(); 
			
			//call Leds.led0Off();
			//RadioStateStop();
			
			//call Leds.led0Off();
			//call Leds.led1Off();
			UcastPending = FALSE;
			call SendReceive.resetUcastDestination();
			//call Leds.led1On();
			}
		//	if(err != SUCCESS){
		//	call SubSend.cancel(msg);
			//call Leds.led1Toggle();
		//	}
		  }	
	  

         async command error_t UcastSend.send(message_t * msg, uint8_t len)
	 { 	
		if(UcastPending){return EBUSY;}
		//call Leds.led0On();
		atomic ucast_ = msg;                
		atomic umsg_data_length = len;	
		atomic ucast_dest = call AMPacket.destination(msg);
		call UcastState.forceState(U_ON);
		atomic UcastPending = TRUE;
	atomic{	if((ucast_dest == PreviousDest) && ( (ReceiverWakeupDelay > 10) && ( ReceiverWakeupDelay < tca_ )))
		{ //wakeup timer
		  //  call Leds.led0Toggle();
		    call WakeupAlarm.start((ReceiverWakeupDelay - 10));
		    PreviousDest = ucast_dest;
		   
	      	} 
		else{ //start timer to calculated delay
		    RadioStateStart();//[Poonam think about optimisation 3 ];
		    call WakeupAlarm.start(tca_);
		    radioStartTimer = call WakeupAlarm.getNow();
		   } }
		
		call SendReceive.setUcastDestination(ucast_dest);
		return SUCCESS;
	 }

	 async command void * UcastSend.getPayload(message_t * msg, uint8_t len)
	{
		return call SubSend.getPayload(msg, len + sizeof(AlphaBcastMsg));
	}
	async command uint8_t UcastSend.maxPayloadLength()
	{
		return call SubSend.maxPayloadLength() - sizeof(AlphaBcastMsg);
	}
	async command error_t UcastSend.cancel(message_t * msg)
	{
		return call SubSend.cancel(msg);
	}

	
      event void RadioPowerControl.startDone(error_t error)
	{ 
	if(error == SUCCESS){
	call RadioState.forceState(R_ON);
//	if(BreqPending){ post createReqSend();}
	//call Leds.led1On();
	
	
	radioStartTime = call DutyCycleCalculator.getNow();
	radioToggleCount = radioToggleCount + 1;
	  }
	
	}


        event void RadioPowerControl.stopDone(error_t error)
	{ 
	if(error == SUCCESS){
	atomic radioStopTime = call DutyCycleCalculator.getNow();
	radioToggleCount = radioToggleCount + 1;
	atomic  { radioOnTime = radioOnTime + (uint32_t)(radioStopTime - radioStartTime); } 
	call RadioState.forceState(R_OFF);
	//call Leds.led1Off();
	//call Leds.led2Off();
	//call Leds.led0Off();
	}
      else{  RadioStateStop(); // call RadioPowerControl.stop(); 
	    }
	}
//*******************************TUMStarted--------------------------------------------------------------------------------------//

	command error_t StdControl.start()
	{	
		atomic tum_ = call AlphaMacTimerControl.getBcastTimerInterval();
		atomic tca_on_ = call AlphaMacTimerControl.getLplAdaptiveTimerInterval();
		atomic tca_ = call AlphaMacTimerControl.getLplTimerInterval();
		//call Leds.led1Toggle();
		atomic {				
			            call BcastTimer.start(20);
			
			if(tca_ > 0){
				    call LplTimer.start(tca_);
				    }
			
			}
		  call UcastState.forceState(U_OFF);
		  call UcastReqState.forceState(U_REQ_OFF);
		  call BcastState.forceState(B_OFF);
		  call DutyCycleCalculator.startOneShot(1000);
		  atomic cycleStartTime = call DutyCycleCalculator.getNow();
		  call RadioPowerControl.start();
              //   call RadioState.forceState(R_STARTING);
		
		return SUCCESS;
	}
 //***************************************------------------------------------------------------------------------------------------//  

	command error_t StdControl.stop()
	{
		call BcastTimer.stop();
		call RadioPowerControl.stop();
		call RadioState.forceState(R_STOPPING);
          	return SUCCESS;
	}

      async event void WakeupAlarm.fired(){ RadioStateStart();
					  }

      async event void ExplicitSyncTimer.fired()
	{
	//call Leds.led1Toggle();
	post sendSyncMsg();
	
	}
/**
LpLtimer alarm tells the receiver to get-up to receive the unicast 
packets from the neighbourhood. For doing this, it sends out 
ReqSendMsg to request the unicast packets. It also initiates the 
LplAdaptive timer to keep the record of waking up interval, when 
LplAdaptive fire, that says stop receiving unicast packets in. 
 */
      async event void LplTimer.fired()
	{
	atomic tca_ = call AlphaMacTimerControl.getLplTimerInterval();
	if(tca_ > 0) {
	        call LplTimer.start(tca_);
		}
	
	if(!BreqPending){
	call UcastReqState.forceState(U_REQ_ON);
	BreqPending = TRUE;
	post createReqSend(); }
	}

      async command error_t SendReceive.ucastSendstart(uint16_t dest)
	{// call Leds.led1Off(); 
	  if(UcastPending){
	  post StartUcastSend();
	  if((call WakeupAlarm.isRunning()) == TRUE){  atomic ReceiverWakeupDelay = (call WakeupAlarm.getNow() - radioStartTimer);
	    call WakeupAlarm.stop(); 
	    PreviousDest = dest; }
	  }
	  return SUCCESS;
	}
      async command error_t SendReceive.setUcastDestination(uint16_t dest)
	{
	if(ucastDestLocked == FALSE){
	atomic ucast_dest = dest ;
	atomic ucastDestLocked = TRUE;
	return SUCCESS;}
	else{ return FAIL;}
	
	}
      async command error_t SendReceive.resetUcastDestination()
	{
	atomic ucast_dest = 0xFF;
	atomic ucastDestLocked = FALSE;
	return SUCCESS;
	}

      async command uint16_t SendReceive.getUcastDestination(){
	  return ucast_dest;  }

      event void DutyCycleCalculator.fired(){
	cycleEndtime = cycleEndtime + (uint16_t) ( call DutyCycleCalculator.getNow() - cycleStartTime );
	if (radioOnTime > preradioOnTime){ DutyCycle =  DutyCycle + (uint16_t) (radioOnTime - preradioOnTime ); preradioOnTime = radioOnTime;}
	//else{DutyCycle = 0;}
	
	//atomic radioOnTime = 0;
	//radioToggleCount = 0;
	call DutyCycleCalculator.stop();
	call DutyCycleCalculator.startOneShot(1000);
        atomic cycleStartTime = call DutyCycleCalculator.getNow();
	
	}

async command uint16_t AlphaTest.getRadioOnTime(){ uint16_t tmp; tmp = DutyCycle; DutyCycle = 0 ; return   (uint16_t)tmp;  }

async command uint16_t AlphaTest.getRadioToggleCount(){uint16_t tmp; tmp = radioToggleCount; radioToggleCount = 0; return (uint16_t)tmp;
						      }

async command uint16_t AlphaTest.getTotalTime(){ uint16_t tmp; tmp = cycleEndtime; cycleEndtime = 0; 
return  (uint16_t) tmp ;  }


}



