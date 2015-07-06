/*
 * Portions of this file are derived from the files PhyConst.h 
 * and ScpConst.h from the original implementation of ALPHA by the 
 * University of Southern California. These files are under the 
 * following license:
 *
 ******
 *
 * Copyright (C) 2005 the University of Southern California.
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * In addition to releasing this program under the LGPL, the authors are
 * willing to dual-license it under other terms. You may contact the authors
 * of this project by writing to Wei Ye, USC/ISI, 4676 Admirality Way, Suite
 * 1001, Marina del Rey, CA 90292, USA.
 *
 *****
 *
 * 
 *
 */

#ifndef __ALPHACONSTANTS_H
#define __ALPHACONSTANTS_H

#ifdef CC2420_DEF_CHANNEL
/*
 * Authors: Wei Ye
 *
 * Physical layer parameters
 */
enum
{
        PHY_BASE_PREAMBLE_LEN = 4,
        PHY_NUM_SYNC_BYTES = 1,
        PHY_MAX_PKT_LEN = 120,
        PHY_WAKEUP_DELAY = 2,
        PHY_TX_BYTE_TIME = 32,
        PHY_MAX_CS_EXT = 3,
        PHY_CS_SAMPLE_INTERVAL = 130,
        PHY_LOADTONE_DELAY = 1,
        PHY_BASE_PRE_BYTES = PHY_BASE_PREAMBLE_LEN + PHY_NUM_SYNC_BYTES
};
#else
#error PHY constants are not defined for this radio
#endif

/*
 * Authors: Poonam Yadav
 *
 * ALPHA-MAC constants that can be used by applications
 */
enum
{
        LPL_MIN_POLL_BYTES = 1,
        LPL_MAX_POLL_BYTES = LPL_MIN_POLL_BYTES + PHY_MAX_CS_EXT,

        ALPHA_GUARD_TIME = 4,
        ALPHA_TONE_CONT_WIN = 7,
        ALPHA_PKT_CONT_WIN = 15,
        ALPHA_NUM_HI_RATE_POLL = 3,
	
        
        // TODO: fix once RTS/CTS is added
        DIFS = 2,
        CSMA_RTS_DURATION = 0,
        CSMA_CTS_DURATION = 0,
        CSMA_ACK_DURATION = 0,
        CSMA_PROCESSING_DELAY = 0,
        
        MAX_BASE_PKT_LEN = PHY_BASE_PRE_BYTES + PHY_MAX_PKT_LEN,
        WAKEUP_DELAY_BYTES = PHY_WAKEUP_DELAY * 1024 / PHY_TX_BYTE_TIME + 1,
        MIN_TONE_LEN = PHY_MAX_CS_EXT + WAKEUP_DELAY_BYTES + LPL_MAX_POLL_BYTES +
                ALPHA_GUARD_TIME,
        TX_TIME_SCHED = (ALPHA_TONE_CONT_WIN + 1 + PHY_MAX_CS_EXT) *
                PHY_CS_SAMPLE_INTERVAL / 1000 + 1 + PHY_LOADTONE_DELAY,
        
        MAX_TONE_TIME = PHY_TX_BYTE_TIME /* * PHY_NUMBER_OF_TONES */ *
                MAX_BASE_PKT_LEN / 1000 + 1 + PHY_LOADTONE_DELAY,
        MAX_CS_WAKEUP_TIME = PHY_WAKEUP_DELAY +
                (ALPHA_TONE_CONT_WIN + 1 + ALPHA_PKT_CONT_WIN + DIFS + PHY_MAX_CS_EXT) * PHY_CS_SAMPLE_INTERVAL / 1000 +
                1  + MIN_TONE_LEN * PHY_TX_BYTE_TIME / 1000 + 1,
        MAX_BCAST_TIME = MAX_CS_WAKEUP_TIME + MAX_TONE_TIME +
                MAX_BASE_PKT_LEN * PHY_TX_BYTE_TIME / 1000 + 1,
        MAX_UCAST_TIME = MAX_BCAST_TIME + CSMA_RTS_DURATION + CSMA_CTS_DURATION  +
                CSMA_ACK_DURATION + CSMA_PROCESSING_DELAY * 4,
        HI_RATE_POLL_PERIOD = MAX_UCAST_TIME,
};

//For the state of the MAC Layer
enum
{	B_OFF = 0,
        B_ON = 1,
};
//For the state of the Radio Layer 

enum
{
        U_OFF = 0,
        U_ON = 1,
	
};
enum
{
        U_REQ_OFF = 0,
        U_REQ_ON = 1,
	
};


enum
{	R_OFF = 0,
        R_ON = 1,
	R_STARTING= 2,
	R_STOPPING = 3,      
};



float ALPHA_SETW = 0.1;
float EPSILON = 0.05;
float SIGMA =  0.053;

#endif

