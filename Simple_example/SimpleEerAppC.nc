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
	* Author: Newlyn Erratt
  */

#if defined(PRINTF_ENABLED)  || defined(PRINTF_ENABLED_COOJA)
#include "printf.h"
#endif

configuration SimpleEerAppC {
}

implementation {

	components SimpleEerC, MainC;
	components new TimerMilliC() as DataTimerC;
	
	components ActiveMessageC;
	components CollectionC as Collector;
	components new CollectionSenderC(0xee);	//data packet type

	#if defined(PRINTF_ENABLED)  || defined(PRINTF_ENABLED_COOJA)
		#if defined(PRINTF_ENABLED_REAL_EXPERIMENT)
		components PrintfC;
		#else
		components SerialPrintfC; // For cooja
		#endif 	
	components SerialStartC;
	#endif



	#if defined(LED_ENABLED)  
	components LedsC;
	SimpleEerC.Leds -> LedsC;
	#endif

	//General wiring
	SimpleEerC.Boot -> MainC;
	SimpleEerC.DataTimer -> DataTimerC;
	
	//Wire radio related
	SimpleEerC.RadioControl -> ActiveMessageC;
	SimpleEerC.RoutingControl -> Collector;
	SimpleEerC.Send -> CollectionSenderC;

	#if defined(SUMMARY_PACKET)
		//Summary packet rate (seconds)
		#ifndef SUMMARY_RATE
		#define SUMMARY_RATE 1024*60*30
		#endif

		components EerInstrumentationP;
		components new TimerMilliC() as SummaryTimerC;
		components new CollectionSenderC(0xCD) as SummarySenderC;
		SimpleEerC.SummarySend -> SummarySenderC;
		SimpleEerC.SummaryTimer -> SummaryTimerC;
		SimpleEerC.EerInstrumentation -> EerInstrumentationP;
	#endif  

	SimpleEerC.RootControl -> Collector;


}
