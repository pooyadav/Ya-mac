/**
 * Turns the Alpha MAC layer on and off as a whole.
 *
 * @author Poonam Yadav
 */
module AlphaSplitControlP
{
	provides interface SplitControl;

	
	uses interface RadioPowerControl;
	//uses interface StdControl as SenderControl;
	uses interface StdControl as BeaconManagerControl;
	uses interface StdControl as BcastControl;
	uses interface State as MacState;
	uses interface State as RadioState;
	uses interface Leds;
	
}
implementation
{
	enum
	{
		S_STOPPED = 0,
		S_STARTING = 1,
		S_STARTED = 2,
		S_STOPPING = 3,
	};
      
	
	
	command error_t SplitControl.start()
	{
		if(call MacState.getState() != S_STOPPED)
			return FAIL;
		call MacState.forceState(S_STARTING);
		call BeaconManagerControl.start();
		call BcastControl.start();
		call RadioState.forceState(R_STARTING);
		
		return call RadioPowerControl.start();
	}
	
	event void RadioPowerControl.startDone(error_t err)
	{
		if(call MacState.getState() == S_STARTING)
		{
			call MacState.forceState(S_STARTED);			
			signal SplitControl.startDone(SUCCESS);
		}
	     
	      call RadioState.forceState(R_ON);
	}
	
	command error_t SplitControl.stop()
	{
		if(call MacState.getState() != S_STARTED)
			return FAIL;
		call MacState.forceState(S_STOPPING);

		call BeaconManagerControl.stop();
		call BcastControl.stop();
		//call SenderControl.stop();	
		call RadioState.forceState(R_STOPPING);
		return call RadioPowerControl.stop();
	}
	
	event void RadioPowerControl.stopDone(error_t err)
	{
		// If we're busy powering everything down
		if(call MacState.getState() == S_STOPPING)
		{
			call MacState.forceState(S_STOPPED);
			signal SplitControl.stopDone(SUCCESS);
			// Signal success
		}
		if(err == SUCCESS) {
		  
		    call RadioState.forceState(R_OFF); }
	}

	

}
