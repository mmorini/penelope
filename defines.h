/* compile-time parameters */

////////////////////////////////
//if compiling for spinning

//define SPINNING
//else weaving


#define CR '\x0D'
#define LF '\x0A'


//FILENAMES:
//weaverDBFileName - PUs database 
#define WDB_FN "PE/PE_TELAI.TXT"
//productsFileName - obsolete
#define PROD_FN  "KMPROD.TXT"
//ordersFileName - orders DB
#define ORD_FN "PE/PE_CATEN.TXT"
//teamsCalFileName - setup teams calendar
#define TC_FN  "PE/PE_CALSQ.TXT"
//weaversCalFileName - weavers calendar
#define WC_FN  "PE/PE_CALTE.TXT"
//ordSerNum2Chains FileName - convert orders numbers to chains
#define ON2CH_FN "PE/PE_ON2CH.TXT"
//results file name 
#define PIAN_FN "PE/PE_OUT.TXT"
//program and dump file names (output module)
#define DUMP_FN "DUMP.TXT"
#define PROG_FN "PE/PROGRAM.TXT"

//////////////////////////////////////////////////////////////

//Evaluator
//time span in seconds: eg. 3600*24*7 = one week
#define REAL_TIME_SPAN 3600*24*720
#define REAL_TIME_TICKS 600
//the time of the day (HHMM, 24h) an order must be ready 
//not to be delayed till the day after
#define TIME_OF_DELIVERY "1200"
//the simulation is supposed to start at 22.00H the day before
//the first available delay cost is made available (last turn)
//as a delta from the TIME_OF_DELIVERY: 2+12 hrs
#define SIMTIME_OFFSET -(3600*14)


//DBInterface:
#define NUM_OF_FAMILIES 5
//#define NUM_OF_SETUPS 4 /*new specs - not true anymore*/
#define NUM_OF_SETUPS 5
#define COSTS_DAYS_SPAN 50
#define CALENDAR_SPAN_DAYS 14
#define ORDERS_LINES_LENGTH 4096
#define WEAVERS_CAL_LINES_LENGTH 1000
#define MAX_SETUP_ORDERS 1000

//GenomaBucket: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
//10000 items take about  45 MB (100 strings)
//50000 items take about 200 MB
#define USE_GB 1
//#define ITEMS 16384 //now defined in Makefiles
#define LOG_FREQ 100

//GMMacro:
#define MAXGL 1024

//ModelSwarm:
//max_weavers also does for max_spinners
#define MAX_WEAVERS 100
//output_freq: Golem statistics (convergency) compute and print
#define OUTPUT_FREQ 1000
//if the first weaver number is 0 w_offset=0, else set at 1 (normally 1)
//(needed in order to correct assignment, first weaver needs to be #0)
#define W_OFFSET 1
//with dual genoma with min=1 not needed anymore
#define MAX_ORDERS 512
//prog_dump_freq: a wannabe prog is dumped every nth steps
#define PROG_DUMP_FREQ 10


//OrderList
//'T' as 'Trattare' = da pianificare -- orders to plan, others to setup
#define PLAN_FLAG "T"

//Weaver
#define HCOMB_TOL 20 //20cm limit
#define CACC_SIG_CHARS 4
#define SETUP_TIMES_COEFF_TO_SECS 3600 
#define DURATIONS_COEFF_TO_SECS 60

//Spinner
#define CRU_USED_CHARS 2


//Tester
#define USE_TESTER 1

//WeaverManager
//#define MAX_HOURS 24000 //1000 days
//#define MAX_WEAVERNUMBER 100


////////////////////////////////
//ERROR EXIT CODES

//#define HALT_ON_ALL_ERRORS

#define PU_QUEUE_OVERFLOW             101
#define PU_NONUNIQUE_IN_DATA          202
#define DUR_FAM_OFFSET_SEARCH_FAILED  201
#define DLV_COST_OFFSET_SEARCH_FAILED 202
#define SETUP_KIND_SEARCH_FAILED      203
#define DUMP_FILE_CREAT_FAILED        301
#define PROG_FILE_CREAT_FAILED        302
#define INSUFFICIENT_SIM_RUN_TIME     501






////////////////////////////////

#ifdef HALT_ON_ALL_ERRORS
#define WARNING_HALT(A) A
#else
#define WARNING_HALT(A) //
#endif


#ifdef SPINNING
#define DBINTERFACE "DBInterface_S.h"
#define PU_KIND "Spinner.h"
#define PU_INITVAL "xx/xx/xx"
//tester (spinner)
#define FIFO_MATCHING_CHARS 8
#else
#define DBINTERFACE "DBInterface_W.h"
#define PU_KIND "Weaver.h"
#define PU_INITVAL "xxxx/xxxxx"
//tester (weaver)
#define FIFO_MATCHING_CHARS 4
#endif






