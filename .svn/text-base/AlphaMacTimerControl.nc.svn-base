 /**
 * Saves the values of four Timers intervals used by Alpha-MAC
 * 
 *
 * @author Poonam Yadav
 */
interface AlphaMacTimerControl
{
async command void setBcastTimerInterval(uint16_t x);
async command void setLplTimerInterval(uint16_t x);
async command void setLplAdaptiveTimerInterval(uint16_t x);
async command void setExplicitBcastTimerInterval(uint16_t x);
async command void setSynTimerError(int16_t x);
async command void setNeighbour(uint16_t x);
async command void setSync(bool x);

async command  uint16_t getBcastTimerInterval();
async command  uint16_t getLplTimerInterval();
async command uint16_t  getLplAdaptiveTimerInterval();
async command uint16_t  getExplicitBcastTimerInterval();
async command int16_t   getSynTimerError();
async command uint16_t getNeighbour();
async command bool getSync();

}
