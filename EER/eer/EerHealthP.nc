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

module EerHealthP {
  provides interface EerHealth;
	uses interface EerParentSelectionHealth;
}

implementation {

  typedef nx_struct HealthCounters {
		nx_uint16_t generated;
		nx_uint16_t forwarded;
		nx_uint16_t total_retx;
		nx_uint16_t dropped;
  } HealthCounters;

  HealthCounters hlth;

	command error_t EerHealth.init() {
		hlth.generated 		= 0;
		hlth.forwarded 		= 0;
		hlth.total_retx 	= 0;
		hlth.dropped 			= 0;
		return SUCCESS;
	}

  command error_t EerHealth.hlth_generated(){
		hlth.generated++;
		return SUCCESS;
	}

	command error_t EerHealth.get_hlth_generated(nx_uint16_t * gen){
		*gen = hlth.generated;
		return SUCCESS;
	}

  command error_t EerHealth.hlth_forwarded(){
		hlth.forwarded++;
		return SUCCESS;
	}

  command error_t EerHealth.get_hlth_forwarded(nx_uint16_t * fwd){
		*fwd = hlth.forwarded;
		return SUCCESS;
	}

  command error_t EerHealth.hlth_retx(){
		hlth.total_retx++;
		return SUCCESS;
	}

  command error_t EerHealth.get_hlth_retx(nx_uint16_t * retx){
		*retx = hlth.total_retx;
		return SUCCESS;
	}

  command error_t EerHealth.hlth_dropped(){
		hlth.dropped++;
		return SUCCESS;
	}

  command error_t EerHealth.get_hlth_dropped(nx_uint16_t * drp){
		*drp = hlth.dropped;
		return SUCCESS;
	}



	command error_t EerHealth.get_hlth_psetSize(nx_uint8_t * psetSize){
		*psetSize = call EerParentSelectionHealth.getCandiateSetSize();
		return SUCCESS;
	}

	command error_t EerHealth.get_hlth_eerParent(nx_uint16_t * eerParent){
		*eerParent = call EerParentSelectionHealth.getBestNeighborFromParentSet();
		return SUCCESS;
	}

}
