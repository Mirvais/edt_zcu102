#include "xcortexr5.h"

XCortexr5_Config XCortexr5_ConfigTable[] __attribute__ ((section (".drvcfg_sec"))) = {
	{
		0xff,  /* access-val */
		0x1dcca1db,  /* cpu-frequency */
		0x0  /* reg */
	}
};