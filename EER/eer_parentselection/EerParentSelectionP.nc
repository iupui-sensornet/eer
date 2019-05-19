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
  */


generic module EerParentSelectionP(uint8_t parentTableSize){

  provides interface EerParentSelectionConfig;
	provides interface EerParentSelectionHealth;
	
  uses interface Random;
}

implementation{

	#ifndef MAX_PARENTSET_SIZE
	#define MAX_PARENTSET_SIZE 1
	#endif

	// Parent set information
	am_addr_t parentSetTable[MAX_PARENTSET_SIZE];
	nx_uint16_t parentSetPathETX[MAX_PARENTSET_SIZE];
	parentSet prntSet; 
	am_addr_t rand_prnt;

	bool parent_init_flag = FALSE;


	command void EerParentSelectionConfig.initializeParentSet(){
		prntSet.setSize 			= 0;
		prntSet.maxPathETX 		= 0;
		prntSet.setETX 				= MAX_METRIC;
		prntSet.bestNeighbor 	= INVALID_ADDR;

		if(parent_init_flag == FALSE){
			prntSet.previousFwder = INVALID_ADDR;	
			parent_init_flag = TRUE;
		}

		rand_prnt 						= INVALID_ADDR;
	}


  command error_t EerParentSelectionConfig.addParentCandidate( routing_table_entry* entry, nx_uint16_t candPathETX)
  {

		nx_uint8_t i;

		if(MAX_PARENTSET_SIZE > 1){
			if(prntSet.setSize < MAX_PARENTSET_SIZE){
				// The candidate can be added
				parentSetTable[prntSet.setSize] = entry->neighbor;
				parentSetPathETX[prntSet.setSize] = candPathETX;
				// Update max path etx
				if(candPathETX > prntSet.maxPathETX){
					prntSet.maxPathETX = candPathETX;
					prntSet.maxPathETXPos = prntSet.setSize; // Becase there is space in the set
				}
				// Update the parent set ETX
				if(candPathETX < prntSet.setETX){
					prntSet.setETX = candPathETX;	
					prntSet.bestNeighbor = entry->neighbor;		
				}
				prntSet.setSize = prntSet.setSize + 1;

				return SUCCESS;			
			}
			else{
				// Candidate set is full
				if(candPathETX < prntSet.maxPathETX){
					// The candidate is better than one of the current members, then exchange them
					parentSetTable[prntSet.maxPathETXPos] = entry->neighbor;
					parentSetPathETX[prntSet.maxPathETXPos] = candPathETX;
					// Update the max path ETX in the set
					// Update the set ETX
					prntSet.maxPathETX = 0;
					prntSet.setETX = MAX_METRIC;
					for(i=0;i<prntSet.setSize;i++){  
						// Start from 1 to avoid the CTP parent
						if(parentSetPathETX[i] >  prntSet.maxPathETX){
							prntSet.maxPathETX = parentSetPathETX[i];
							prntSet.maxPathETXPos = i;
						}
						if(parentSetPathETX[i] <  prntSet.setETX){  
							// Find the lowest pathETX in the parent set and then compare with the CTP prnt
							prntSet.setETX = parentSetPathETX[i];
							prntSet.bestNeighbor = parentSetTable[i];		
						}
					}

				}	
				else{
					// Debug
				}	
			}
		}

		return SUCCESS;			
	}


	command am_addr_t EerParentSelectionConfig.drawRandomParent(){
		// Selects a parent randomly from the candidate set	
		uint16_t rnd;

		// Parent set is empty
		if(prntSet.setSize == 0){
			return INVALID_ADDR;
		}	

		rnd = call Random.rand16();
		rnd = rnd % prntSet.setSize;

		rand_prnt = parentSetTable[rnd];  

		if(prntSet.setSize == 1){
			prntSet.previousFwder = INVALID_ADDR;
			return rand_prnt;
		}
		else{
			if(prntSet.previousFwder == INVALID_ADDR){
				// Set the previous forwarder flag
				prntSet.previousFwder = rand_prnt;
				return rand_prnt;
			}
			else{
				while(prntSet.previousFwder == rand_prnt){
					// Draw a new parent
					rnd = call Random.rand16();
					rnd = rnd % prntSet.setSize;
					rand_prnt = parentSetTable[rnd];  
				}	
				// Set the flag to the new parent
				prntSet.previousFwder = rand_prnt;
				return rand_prnt;		
			}
		}

	}

	command error_t EerParentSelectionConfig.getParentSetETX( nx_uint16_t* parentSetETX, nx_uint8_t* parentSetSize ){
		
		// Parent set is empty
		if(prntSet.setSize == 0){

			*parentSetETX = MAX_METRIC;
			*parentSetSize = prntSet.setSize;
			return FAIL;
		}
		else{

			*parentSetETX = prntSet.setETX;
			*parentSetSize = prntSet.setSize;
			return SUCCESS;
		}
	}

	command nx_uint8_t EerParentSelectionConfig.getParentSetSize(){
		return prntSet.setSize;
	}


	command nx_uint8_t EerParentSelectionHealth.getCandiateSetSize(){
		return prntSet.setSize;
	}

	command nx_uint16_t EerParentSelectionHealth.getBestNeighborFromParentSet(){
		return prntSet.bestNeighbor;
	}

 
}





