#ifndef __ALPHABCASTMSG_H
#define __ALPHABCASTMSG_H

//#include "AlphaConstants.h"

typedef nx_struct AlphaBcastMsg
{
	nx_bool Sync; //this field for test purpose which reflects if a node is synch with the its neighbourhood
	nx_uint16_t bversion; //this field carry information about the bcast version sent out by mac layer, irrespective of the Bcast from application layer
	nx_uint16_t Sync_error; //this contain max value of sync value drift of a node from its neighboorhood
	nx_uint16_t neighbour; //approximate value of neighbours(it is total no of neighbours a node seen from its previous broadcast to recent broadcast.
} AlphaBcastMsg;


enum
{
        AM_REQSENDMSG = 199,
};

enum
{
	AM_ALPHABCASTMSG = 0x73,
	AM_ALPHASYNCMSG = AM_ALPHABCASTMSG - 1,
};

#endif /* __ALPHABCASTMSG_H */
