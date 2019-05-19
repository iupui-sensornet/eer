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

#include <Timer.h>
#include "simple_eer.h"

#if defined(PRINTF_ENABLED)  || defined(PRINTF_ENABLED_COOJA)
#include "printf.h"
#endif

module SimpleEerC {
	uses interface Boot;
	uses interface SplitControl as RadioControl;
	uses interface StdControl as RoutingControl;
	uses interface Send;
	uses interface Timer<TMilli> as DataTimer;
	
	#if defined(LED_ENABLED)
	uses interface Leds;
	#endif
	
	#if defined(SUMMARY_PACKET)
	uses interface Send as SummarySend;
	uses interface Timer<TMilli> as SummaryTimer;
	uses interface EerInstrumentation;
	#endif

	uses interface RootControl;

}

implementation {
	message_t packet;

	bool ignoreBusyFlags	= FALSE;	// Set to TRUE to ignore BUSY flags for all packet
	bool dataSendBusy 		= FALSE;
	

	#if defined(SUMMARY_PACKET)
	message_t summary_packet;
	bool summarySendBusy;
	#endif
	
	uint16_t count = 0;
	uint16_t voltage;
	uint16_t temperature;
	uint16_t humidity;
	uint16_t adc[7];   // use an array to store adc readings

	// temp variable for loop
	uint16_t i;

	event void Boot.booted() {

		#if defined(PRINTF_ENABLED)  || defined(PRINTF_ENABLED_COOJA)
		printf("** Mote booted! **\n");
		printfflush();
		#endif
		call RadioControl.start();

	}
	
  // Start the sampling timer once the radio is started
	event void RadioControl.startDone(error_t err) {
		if (err != SUCCESS)
			call RadioControl.start();
		else {

			if (TOS_NODE_ID == SINK_NODEID) {						// FOR COOJA:
				call RootControl.setRoot();								// USE NODE 1 AS ROOT. THIS NODE PRINTS THE PACKETS FROM THE FORWARDING ENGINE
				#if defined(PRINTF_ENABLED)  || defined(PRINTF_ENABLED_COOJA)
				printf("** Root started **\n");
				printfflush();
				#endif
			}

			// Start routing protocol
			call RoutingControl.start();
			if (TOS_NODE_ID != SINK_NODEID){
				// Data packet timer
				call DataTimer.startPeriodic( (uint32_t)DATA_RATE);
			
				// Summary packet timer
				#if defined(SUMMARY_PACKET)
				call SummaryTimer.startPeriodic( (uint32_t)SUMMARY_RATE);
				#endif	


				#if defined(PRINTF_ENABLED)  
				printf("\nAPP: timers started\n");
				printfflush();
				#endif
			}
		}
	}

	event void RadioControl.stopDone(error_t err) {}

	//task to send our data
	task void sendMessage() {
		ReadingMsg* msg = (ReadingMsg*)call Send.getPayload(&packet, sizeof(ReadingMsg));
		
		msg->flag = 0xFF;
		msg->count = count++;
	
		if (call Send.send(&packet, sizeof(ReadingMsg)) == SUCCESS){
			#if defined(PRINTF_ENABLED)  
			printf("APP: send (S)\n");
			printfflush();
			#endif

			#if defined(LED_ENABLED)
			call Leds.led0On();	// if send successful, red led ON (off after sendDone)
			#endif

		}
		else{
			dataSendBusy = FALSE;
			#if defined(PRINTF_ENABLED)  
			printf("APP: send (F)\n");
			printfflush();
			#endif			
			}
	}

	event void DataTimer.fired() {

		#if defined(LED_ENABLED)
			call Leds.led1Toggle();	// timer fired, green led blink
		#endif

		if (!dataSendBusy || ignoreBusyFlags){
			dataSendBusy = TRUE;
			#if defined(LED_ENABLED)
			call Leds.led2Toggle();	// start reading, yellow led blink
			#endif
			#if defined(PRINTF_ENABLED)  
			printf("APP: Timer: Send message\n");
			printfflush();
			#endif
			post sendMessage();
		}
		else{																// else: skip this reading
			#if defined(PRINTF_ENABLED)  
	  		printf("APP: Timer: BUSY\n");
	  		printfflush();
			#endif
		}

	}


	event void Send.sendDone(message_t* m, error_t err) {
		dataSendBusy = FALSE;

		#if defined(PRINTF_ENABLED)  
  		printf("APP: send done: ");
		#endif

		if(err == SUCCESS){
			#if defined(PRINTF_ENABLED)  
			printf(" (S)\n");
			#endif

			#if defined(LED_ENABLED)
			call Leds.led0Off();	// if send successful, red led OFF
			#endif
		}
		else{
			#if defined(PRINTF_ENABLED)  
			printf(" (F)\n");
			#endif
		}
		#if defined(PRINTF_ENABLED)  
			printfflush();
		#endif
	}


//---------------------------------- SUMMARY PACKET  -----------------------------------//
#if defined(SUMMARY_PACKET)	

	event void SummaryTimer.fired() {
		uint8_t msgsize;

		#if defined(PRINTF_ENABLED)  
		printf("APP: Summary timer fired\n");
		printfflush();
		#endif

		if(!summarySendBusy || ignoreBusyFlags){

			// Define the node total time
			//call CtpInstrumentation.set_total_time( call TrafficMonitor.getCurrentTime() );

			msgsize = call EerInstrumentation.summary_size();
			call EerInstrumentation.summary(call SummarySend.getPayload(&summary_packet, msgsize));

			if (call SummarySend.send(&summary_packet, msgsize) != SUCCESS) {
				#if defined(PRINTF_ENABLED)  
				printf("APP: SummaryTimer: Send (F)\n");
				printfflush();
				#endif
			} 
			else {
				summarySendBusy = TRUE;
				#if defined(PRINTF_ENABLED)  
				printf("APP: SummaryTimer: Send (S)\n");
				printfflush();
				#endif
			}
		}
	}
	
	event void SummarySend.sendDone(message_t* m, error_t err) {
		summarySendBusy = FALSE;
		#if defined(PRINTF_ENABLED)  
		printf("APP: Summary pktSend done\n");
		printfflush();
		#endif
	}

#endif




}
