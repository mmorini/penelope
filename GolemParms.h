// Parm.h
//
// Here we set maximum dimension of arrays and storage areas
// and default values for parameters
//--------------------------------------------------------------------
// Default values
#define DEFAULT_TURNOVER_RATE             0.5
#define DEFAULT_CROSSOVER_RATE            0.5
#define DEFAULT_RANDOM_CROSSPOINTS        1
#define DEFAULT_UNIVOCAL_CROSSPOINTS      1
#define DEFAULT_CROSSPOINTS               1
#define DEFAULT_MUTATION_RATE             0.0005
#define DEFAULT_CONFIDENCE                0.99
#define DEFAULT_RULE_LENGTH              32
#define DEFAULT_GENOME_LENGTH            32
#define DEFAULT_NUMBER_OF_RULES         128
#define DEFAULT_NUMBER_OF_GENOMES         1
#define DEFAULT_RANDOM_SEED          123456
#define DEFAULT_BEST_WILL_SURVIVE        'f'

//--------------------------------------------------------------------
// Min values
#define MIN_TURNOVER_RATE            0.05
#define MIN_CROSSOVER_RATE           0.10
#define MIN_RANDOM_CROSSPOINTS       1
#define MIN_UNIVOCAL_CROSSPOINTS     1
#define MIN_MUTATION_RATE            0.0000
#define MIN_CONFIDENCE               0.95
#define MIN_RULE_LENGTH              2
#define MIN_GENOMA_LENGTH            2
#define MIN_NUMBER_OF_RULES          16
#define MIN_NUMBER_OF_GENOMI          1

//--------------------------------------------------------------------
// Max values
#define MAX_TURNOVER_RATE            1.0
#define MAX_CROSSOVER_RATE           1.0
#define MAX_RANDOM_CROSSPOINTS       16
#define MAX_UNIVOCAL_CROSSPOINTS     64
#define MAX_MUTATION_RATE            0.005
#define MAX_CONFIDENCE               0.99
#define MAX_RULE_LENGTH           1024
#define MAX_GENOMA_LENGTH         1024
#define MAX_NUMBER_OF_RULES       1024000
#define MAX_NUMBER_OF_GENOMI      1024

//MAX_ORDERS + MAX_WEAVERS must not exceed MAX_RULE_LENGTH
