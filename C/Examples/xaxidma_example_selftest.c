// xaxidma_example_selftest.c

#include "xaxidma.h"
#include "xparameters.h"
#include "xdebug.h"

/******************** Constant Definitions **********************************/

/*
 * Device hardware build related constants.
 */

#ifndef TESTAPP_GEN
#ifndef SDT
#define DMA_DEV_ID		XPAR_AXIDMA_0_DEVICE_ID
#endif
#endif

/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/

#ifndef SDT
int AxiDMASelfTestExample(u16 DeviceId);
#else
int AxiDMASelfTestExample(UINTPTR BaseAddress);
#endif

/************************** Variable Definitions *****************************/
/*
 * Device instance definitions
 */
XAxiDma AxiDma;


/*****************************************************************************/
/**
* The entry point for this example. It invokes the example function,
* and reports the execution status.
*
* @param	None.
*
* @return
*		- XST_SUCCESS if example finishes successfully
*		- XST_FAILURE if example fails.
*
* @note		None.
*
******************************************************************************/
#ifndef TESTAPP_GEN
int main()
{
	int Status;

	xil_printf("\r\n--- Entering main() --- \r\n");

	/* Run the poll example for simple transfer */
#ifndef SDT
	Status = AxiDMASelfTestExample(DMA_DEV_ID);
#else
	Status = AxiDMASelfTestExample(XPAR_XAXIDMA_0_BASEADDR);
#endif

	if (Status != XST_SUCCESS) {
		xil_printf("AxiDMASelfTest Example Failed\r\n");
		return XST_FAILURE;
	}

	xil_printf("Successfully ran AxiDMASelfTest Example\r\n");
	xil_printf("--- Exiting main() --- \r\n");

	return XST_SUCCESS;

}
#endif

/*****************************************************************************/
/**
* This function performance a reset of the DMA device and checks the device is
* coming out of reset or not.
*
* @param	DeviceId is the DMA device id.
*
* @return
*		- XST_SUCCESS if channel reset is successful
*		- XST_FAILURE if channel reset fails.
*
* @note		None.
*
******************************************************************************/
#ifndef SDT
int AxiDMASelfTestExample(u16 DeviceId)
#else
int AxiDMASelfTestExample(UINTPTR BaseAddress)
#endif
{
	XAxiDma_Config *CfgPtr;
	int Status = XST_SUCCESS;

#ifndef SDT
	CfgPtr = XAxiDma_LookupConfig(DeviceId);
#else
	CfgPtr = XAxiDma_LookupConfig(BaseAddress);
#endif
	if (!CfgPtr) {
		return XST_FAILURE;
	}

	Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	Status = XAxiDma_Selftest(&AxiDma);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return Status;
}
