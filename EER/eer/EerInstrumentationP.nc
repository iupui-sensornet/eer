/*
 * Copyright (c) 2016 Indiana University Purdue University Indianapolis
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 *
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

 /*
  * Author: Miguel Navarro
	* Author: Xiaoyang Zhong
  * Author: Yimei Li
  */

module EerInstrumentationP {
  provides interface EerInstrumentation;
}

implementation {

  typedef nx_struct StatCounters {
    nx_uint16_t ctrl_ntxpkt;
    nx_uint16_t ctrl_nrxpkt;
    nx_uint16_t ctrl_nparentchange;
    nx_uint16_t ctrl_ntricklereset;
    
    nx_uint16_t data_ntxpkt;
    nx_uint16_t data_nrxpkt;
    nx_uint16_t data_nrxacks;
    nx_uint16_t data_nqueuedrops;
    nx_uint16_t data_ndups;
    nx_uint16_t data_ninconsistencies;

		// Added from the data packet
		nx_uint32_t total_time;	
		//nx_uint16_t dutycycle;
		// values from the flash    
		//nx_uint16_t flash_node_id;
		//nx_uint8_t  flash_wdt_resets;

  } StatCounters;

  StatCounters stats;

  command error_t EerInstrumentation.init() {
    stats.ctrl_ntxpkt = 0;
    stats.ctrl_nrxpkt = 0;
    stats.ctrl_nparentchange = 0;
    stats.ctrl_ntricklereset = 0;
 
    stats.data_ntxpkt = 0;
    stats.data_nrxpkt = 0;
    stats.data_nrxacks = 0;
    stats.data_nqueuedrops = 0;
    stats.data_ndups = 0;
    stats.data_ninconsistencies = 0;

		stats.total_time = 0;

    return SUCCESS;

  }
    
  command error_t EerInstrumentation.summary(nx_uint8_t *buf) {
    memcpy(buf, &stats, sizeof(StatCounters));
    return SUCCESS;
  }


  command uint8_t EerInstrumentation.summary_size() {
    return sizeof(StatCounters);
  }


  command error_t EerInstrumentation.ctrl_txpkt() {
    stats.ctrl_ntxpkt++;
    return SUCCESS;
  }

  command error_t EerInstrumentation.ctrl_rxpkt() {
    stats.ctrl_nrxpkt++;
    return SUCCESS;
  }

  command error_t EerInstrumentation.ctrl_parentchange() {
    stats.ctrl_nparentchange++;
    return SUCCESS;
  }

  command error_t EerInstrumentation.ctrl_tricklereset() {
    stats.ctrl_ntricklereset++;
    return SUCCESS;
  }

  command error_t EerInstrumentation.data_txpkt() {
    stats.data_ntxpkt++;
    return SUCCESS;
  }

  command error_t EerInstrumentation.data_rxpkt() {
    stats.data_nrxpkt++;
    return SUCCESS;
  }

  command error_t EerInstrumentation.data_rxack() {
    stats.data_nrxacks++;
    return SUCCESS;
  }

  command error_t EerInstrumentation.data_queuedrop() {
    stats.data_nqueuedrops++;
    return SUCCESS;
  }

  command error_t EerInstrumentation.data_pktdup() {
    stats.data_ndups++;
    return SUCCESS;
  }

  command error_t EerInstrumentation.data_inconsistent() {
    stats.data_ninconsistencies++;
    return SUCCESS;
  }

  command error_t EerInstrumentation.set_total_time(nx_uint32_t t){
		stats.total_time = t;
		return SUCCESS;
	}

	// New commands
	/*
  command error_t CtpInstrumentation.set_dutycycle(nx_uint16_t dc){
		stats.dutycycle = dc;
		return SUCCESS;
	}

  command error_t CtpInstrumentation.set_flash_node_id(nx_uint16_t fnid){
		stats.flash_node_id = fnid;
		return SUCCESS;
	}

  command error_t CtpInstrumentation.set_flash_wdt_resets(nx_uint8_t fwdtr){
		stats.flash_wdt_resets = fwdtr;
		return SUCCESS;
	}
	*/
 
}
