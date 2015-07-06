/**
 * Automatically performs periodic LPL checks.
 *
 * @author Poonam Yadav
 */
module AlphaBeaconManagerP
{
	provides interface AlphaBeaconManager;
	provides interface LowPowerListening;
	provides interface StdControl;
	provides interface AlphaMacTimerControl;
	  
	uses interface ChannelMonitor;
	uses interface Leds;
	uses interface State;
}
implementation
{
	enum
	{
		S_IDLE = 0,
		S_CHECKING = 1,
	};
	
	enum
	{
		DUTY_ON_TIME = 6
	};
	
	bool running_ = FALSE;
	uint16_t ms_ = 0;
	uint16_t bti_ = 2000 * DUTY_ON_TIME;  //Bcast Time Interval
	uint16_t lti_ = 200 * DUTY_ON_TIME;  //Lpl Time Interval
	uint16_t lati_ = 50 * DUTY_ON_TIME; //Lpl Adaptive Time Interval
        uint16_t ebti_ = 200 * DUTY_ON_TIME; // Explicit Bcast Time Interval 
	int16_t syn_error = 0;
	uint16_t neighbour_ = 0;
	bool sync_ = FALSE;


	uint16_t getActualDutyCycle(uint16_t dutyCycle);

		
	async event void ChannelMonitor.busy()
	{
		if(call State.isIdle())
			return;
		// If the check isn't for us, ignore it
			
		call State.toIdle();
		signal AlphaBeaconManager.activityDetected(TRUE);
		// Move into the idle state and signal that the channel is busy
	}
	
	async event void ChannelMonitor.free()
	{
		if(call State.isIdle())
			return;
				
		call State.toIdle();
		signal AlphaBeaconManager.activityDetected(FALSE);
		// Move into the idle state and signal that the channel is free
	}
	
	async event void ChannelMonitor.error() { }
	
	async command void LowPowerListening.setLocalSleepInterval(uint16_t ms)
	{
		atomic lti_ = ms;

	}
	
	async command uint16_t LowPowerListening.getLocalSleepInterval()
	{
		atomic return lti_;
	}
	
	async command void LowPowerListening.setLocalDutyCycle(uint16_t dutyCycle)
	{
		uint16_t ms = call LowPowerListening.dutyCycleToSleepInterval(dutyCycle);
		call LowPowerListening.setLocalSleepInterval(ms);
	}
	
	async command uint16_t LowPowerListening.getLocalDutyCycle()
	{
		uint16_t ms = call LowPowerListening.getLocalSleepInterval();
		return call LowPowerListening.sleepIntervalToDutyCycle(ms);
	}
	
	async command uint16_t LowPowerListening.dutyCycleToSleepInterval(uint16_t dutyCycle)
	{
		dutyCycle = getActualDutyCycle(dutyCycle);
		if(dutyCycle == 10000)
			return 0;
		
		return (DUTY_ON_TIME * (10000 - dutyCycle)) / dutyCycle;
	}
	
	async command uint16_t LowPowerListening.sleepIntervalToDutyCycle(uint16_t ms)
	{
		if(ms == 0)
			return 10000;
		return getActualDutyCycle((DUTY_ON_TIME * 10000) / (ms + DUTY_ON_TIME));
	}
	
	command error_t StdControl.start()
	{
		return SUCCESS;
	}

	command error_t StdControl.stop()
	{
		return SUCCESS;
	}

	uint16_t getActualDutyCycle(uint16_t dutyCycle)
	{
		if(dutyCycle > 10000)
			return 10000;
		else if(dutyCycle == 0)
			return 1;
		return dutyCycle;
	}
// 	async event void ExplicitBcastTimer.fired()
// 	{ }


async command void AlphaMacTimerControl.setBcastTimerInterval(uint16_t x){ atomic bti_ = x;}
async command void AlphaMacTimerControl.setLplTimerInterval(uint16_t x){ atomic lti_ = x;}
async command void AlphaMacTimerControl.setLplAdaptiveTimerInterval(uint16_t x){ atomic lati_ = x;}
async command void AlphaMacTimerControl.setExplicitBcastTimerInterval(uint16_t x){ atomic ebti_ = x;}
async command void AlphaMacTimerControl.setSynTimerError(int16_t x){ atomic syn_error = x; }
async command void AlphaMacTimerControl.setNeighbour(uint16_t x){ atomic neighbour_ = x; }
async command void AlphaMacTimerControl.setSync(bool x){ atomic sync_ = x;}

async command  uint16_t AlphaMacTimerControl.getBcastTimerInterval(){ atomic return bti_ ;}
async command  uint16_t AlphaMacTimerControl.getLplTimerInterval(){ atomic return lti_ ; }
async command uint16_t  AlphaMacTimerControl.getLplAdaptiveTimerInterval(){ atomic return lati_ ;}
async command uint16_t  AlphaMacTimerControl.getExplicitBcastTimerInterval(){ atomic return ebti_ ;}
async command int16_t AlphaMacTimerControl.getSynTimerError(){ atomic return syn_error; }
async command uint16_t AlphaMacTimerControl.getNeighbour(){ atomic return neighbour_; }
async command bool AlphaMacTimerControl.getSync(){atomic return sync_ ;}


}
