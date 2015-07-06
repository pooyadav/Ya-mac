/**
 * Turns the A-MAC layer on and off as a whole.
 *
 * @author Poonam Yadav
 */
configuration AlphaSplitControlC
{
	provides interface SplitControl;
	
	uses interface RadioPowerControl;
	uses interface StdControl as BeaconManagerControl;
	uses interface StdControl as BcastControl;
	uses interface State as RadioState;
}
implementation
{
	components AlphaSplitControlP;
	components new StateC();
	components LedsC;
	

	SplitControl = AlphaSplitControlP;
	
	
	AlphaSplitControlP.RadioPowerControl = RadioPowerControl;
	AlphaSplitControlP.BeaconManagerControl = BeaconManagerControl;
	AlphaSplitControlP.BcastControl = BcastControl;
	AlphaSplitControlP.MacState -> StateC;
	AlphaSplitControlP.Leds -> LedsC;
	AlphaSplitControlP.RadioState = RadioState;
	
}
