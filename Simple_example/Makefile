COMPONENT=SimpleEerAppC

# Define max packet size, including in-network processing layer
CFLAGS += -DTOSH_DATA_LENGTH=57

CFLAGS += -DSINK_SLEEPING
CFLAGS += -DSINK_NODEID=1		## the id of the sink

# ###########################EER Routing protocol #################################
appEER = EER
CFLAGS += -I../$(appEER) \
          -I../$(appEER)/4bitle \
          -I../$(appEER)/eer \
          -I../$(appEER)/eer_parentselection 


# (EER) Maximum parent set size
CFLAGS += -DMAX_PARENTSET_SIZE=5

# (EER) Allowed retransmissions without penalization in the link estimator
# This value should be less than the default retransmission for each forwarder node
CFLAGS += -DEER_ALLOWED_RETXS=1

CFLAGS += -DEER_MAX_BEACON_INT=1024*60*30 # 30 minutes

##################### Set timer parameters ######################################################
# Set initial sampling time (milliseconds)
CFLAGS += -DDATA_RATE=1024*60*1							# 60s

# Enable/Disable summary packets from ctp Instrumentation 
# also define the interval between each summary packet (in milliseconds)
CFLAGS += -DSUMMARY_PACKET
CFLAGS += -DSUMMARY_RATE=1024*60*4							# 4x data packets

#################################################################################################

##################### Set radio parameters ######################################################
# Set radio channel (if you use sniffer, the channel should be 26)
# CC2420 default channel is 26, we can use 11~26
CFLAGS += -DCC2420_DEF_CHANNEL=26

# RF230  default channel is 11, we can use 11~26
CFLAGS += -DRF230_DEF_CHANNEL=26

# Set radio power
# CC2420 default is 31(MAX), we can use 31,27,23,19,15,11,7,3(MIN)
CFLAGS += -DCC2420_DEF_RFPOWER=31
# RF230  default is 0(MAX), we can use 0~15(MIN)
CFLAGS += -DRF230_DEF_RFPOWER=0
#################################################################################################


# Enable/disable LEDs (Comment it out to disable LEDs)
#CFLAGS += -DLED_ENABLED

##################### LPL and compiling path ####################################################
# Default LPL
CFLAGS += -DLOW_POWER_LISTENING
CFLAGS += -DLPL_DEF_LOCAL_WAKEUP=1024
CFLAGS += -DLPL_DEF_REMOTE_WAKEUP=1024
CFLAGS += -DDELAY_AFTER_RECEIVE=20

# hardware acks for cc2420
CFLAGS += -DCC2420_HW_ACKNOWLEDGEMENTS

# Needed in the CC2420 driver (not CC2420X) to listen during enough time
CFLAGS += -DMAX_LPL_CCA_CHECKS=1100   #1500 for heterogeneous networks
#CFLAGS += -DSOFTWAREACK_TIMEOUT=2000  # RFXLINK


# Printf (comment to remove printf)
CFLAGS += -I$(TOSDIR)/lib/printf
CFLAGS += -DNEW_PRINTF_SEMANTICS
#CFLAGS += -DPRINTF_ENABLED
CFLAGS += -DPRINTF_ENABLED_COOJA
#CFLAGS += -DPRINTF_ENABLED_REAL_EXPERIMENT # USE ONLY IN REAL EXPERIMENT TO ADD TIME IN THE PRINTF
CFLAGS += -DPRINTF_BUFFER_SIZE=900

include $(MAKERULES)
