//=============================================================================
// Includes
//=============================================================================
/* Pull in the AXI DMA driver, platform parameter
   definitions, debug helpers, and sleep support
   used by the polling loops. */

#include "xaxidma.h"
#include "xparameters.h"
#include "xdebug.h"
#include "sleep.h"
//-----------------
#ifdef __aarch64__
    #include "xil_mmu.h"
#endif
//-----------------
#if defined(XPAR_UARTNS550_0_BASEADDR)
    #include "xuartns550_l.h"
#endif
//-----------------
#if (!defined(DEBUG))
    extern void xil_printf(const char *format, ...);
#endif


//=============================================================================
// Constant Definitions
//=============================================================================
/* This section defines the DMA device ID, DDR base
   address, descriptor memory regions, packet buffer
   regions, and a few example-specific constants such
   as packet length and timeout count. */

#ifndef SDT
    #define DMA_DEV_ID              XPAR_AXIDMA_0_DEVICE_ID
    //-----------------
    #ifdef XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
        #define DDR_BASE_ADDR       XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
    //-----------------
    #elif defined(XPAR_MIG7SERIES_0_BASEADDR)
        #define DDR_BASE_ADDR       XPAR_MIG7SERIES_0_BASEADDR
    //-----------------
    #elif defined(XPAR_MIG_0_C0_DDR4_MEMORY_MAP_BASEADDR)
        #define DDR_BASE_ADDR       XPAR_MIG_0_C0_DDR4_MEMORY_MAP_BASEADDR
    //-----------------
    #elif defined(XPAR_PSU_DDR_0_S_AXI_BASEADDR)
        #define DDR_BASE_ADDR       XPAR_PSU_DDR_0_S_AXI_BASEADDR
    #endif
#else
    #ifdef XPAR_MEM0_BASEADDRESS
        #define DDR_BASE_ADDR       XPAR_MEM0_BASEADDRESS
    #endif
#endif

#ifndef DDR_BASE_ADDR
    #warning CHECK FOR THE VALID DDR ADDRESS IN XPARAMETERS.H, DEFAULT SET TO 0x01000000
    #define MEM_BASE_ADDR           0x01000000
#else
    #define MEM_BASE_ADDR           (DDR_BASE_ADDR + 0x1000000)
#endif

/* Descriptor storage in DDR */
#define TX_BD_SPACE_BASE        (MEM_BASE_ADDR)
#define TX_BD_SPACE_HIGH        (MEM_BASE_ADDR + 0x00000FFF)
#define RX_BD_SPACE_BASE        (MEM_BASE_ADDR + 0x00001000)
#define RX_BD_SPACE_HIGH        (MEM_BASE_ADDR + 0x00001FFF)

/* Packet buffer storage in DDR */
#define TX_BUFFER_BASE          (MEM_BASE_ADDR + 0x00100000)
#define RX_BUFFER_BASE          (MEM_BASE_ADDR + 0x00300000)
#define RX_BUFFER_HIGH          (MEM_BASE_ADDR + 0x004FFFFF)

/* Example parameters */
#define MAX_PKT_LEN             0x20
#define MARK_UNCACHEABLE        0x701
#define TEST_START_VALUE        0xC
#define POLL_TIMEOUT_COUNTER    1000000U


//=============================================================================
// Function Prototypes
//=============================================================================
/* These helper functions break the example into
   smaller parts: UART setup, RX ring setup, TX
   ring setup, TX packet submission, received data
   check, and final DMA completion handling. */

#if defined(XPAR_UARTNS550_0_BASEADDR)
static void Uart550_Setup(void);
#endif

static int RxSetup(XAxiDma *AxiDmaInstPtr);
static int TxSetup(XAxiDma *AxiDmaInstPtr);
static int SendPacket(XAxiDma *AxiDmaInstPtr);
static int CheckData(void);
static int CheckDmaResult(XAxiDma *AxiDmaInstPtr);


//=============================================================================
// Global Variables
//=============================================================================
/* AxiDma is the DMA driver instance used
   throughout the example. Packet points at the TX
   buffer in DDR and is used to build the test
   payload. */

XAxiDma AxiDma;

/* The TX packet buffer must be aligned in a way
   the DMA can legally access. In this example it
   is placed directly at a fixed DDR address. */
u32 *Packet = (u32 *)TX_BUFFER_BASE;


//=============================================================================
// main()
//=============================================================================
/* High-level program flow:

   1. Optionally initialize the UART for readable
      console output.
   2. Mark descriptor memory uncached on AArch64
      systems.
   3. Look up the DMA configuration and initialize
      the driver.
   4. Confirm the hardware is actually built in SG
      mode.
   5. Set up TX and RX descriptor rings.
   6. Submit one TX packet.
   7. Poll until TX and RX complete, then verify
      the data. */

int main(void)
{
    int             Status;
    XAxiDma_Config *Config;

#if defined(XPAR_UARTNS550_0_BASEADDR)
    Uart550_Setup();
#endif

    xil_printf("\r\n--- Entering main() --- \r\n");

#ifdef __aarch64__
    /* Descriptor memory is shared between CPU
       software and DMA hardware. Making BD space
       uncacheable avoids stale descriptor
       contents/status when the DMA reads or
       updates them. */
    Xil_SetTlbAttributes(TX_BD_SPACE_BASE, MARK_UNCACHEABLE);
    Xil_SetTlbAttributes(RX_BD_SPACE_BASE, MARK_UNCACHEABLE);
#endif

#ifndef SDT
    /* Look up the DMA instance configuration from
       the BSP-generated device definitions using
       the DMA device ID. */
    Config = XAxiDma_LookupConfig(DMA_DEV_ID);
    //=================================
    if (!Config) {

        xil_printf("No config found for %d\r\n", DMA_DEV_ID);
        //-----------------
        return XST_FAILURE;
    }
#else
    /* In SDT builds the configuration lookup is
       done using the DMA base address instead of
       the older device ID flow. */
    Config = XAxiDma_LookupConfig(XPAR_XAXIDMA_0_BASEADDR);
    //=================================
    if (!Config) {

        xil_printf(
            "No config found for %d\r\n",
            XPAR_XAXIDMA_0_BASEADDR
        );
        //-----------------
        return XST_FAILURE;
    }
#endif

    /* Bind the driver instance to the discovered
       hardware configuration. After this call the
       software can access the DMA channels and
       rings. */
    //=================================
    Status = XAxiDma_CfgInitialize(&AxiDma, Config);
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf("Initialization failed %d\r\n", Status);
        //-----------------
        return XST_FAILURE;
    }

    /* This example is specifically for Scatter
       Gather mode. If the hardware was built in
       Simple DMA mode, stop here because the BD
       ring flow below would not apply. */
    //=================================
    if (!XAxiDma_HasSg(&AxiDma)) {

        xil_printf("Device configured as Simple mode \r\n");
        //-----------------
        return XST_FAILURE;
    }

    /* TX setup creates and starts the transmit
       descriptor ring. RX setup creates, fills,
       submits, and starts the receive ring so that
       buffers are already posted before any
       streamed data arrives. */
    //=================================
    Status = TxSetup(&AxiDma);
    //=================================
    if (Status != XST_SUCCESS) {

        //-----------------
        return XST_FAILURE;
    }

    //=================================
    Status = RxSetup(&AxiDma);
    //=================================
    if (Status != XST_SUCCESS) {

        //-----------------
        return XST_FAILURE;
    }

    /* Build one TX packet in memory, allocate one
       TX descriptor, attach the TX buffer to it,
       and submit it to hardware. */
    //=================================
    Status = SendPacket(&AxiDma);
    //=================================
    if (Status != XST_SUCCESS) {

        //-----------------
        return XST_FAILURE;
    }

    /* Poll for TX completion and RX completion,
       verify the received data, then reclaim and
       recycle the descriptors. */
    //=================================
    Status = CheckDmaResult(&AxiDma);
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf("AXI DMA SG Polling Example Failed\r\n");
        //-----------------
        return XST_FAILURE;
    }

    xil_printf("Successfully ran AXI DMA SG Polling Example\r\n");
    xil_printf("--- Exiting main() --- \r\n");

    //=================================
    if (Status != XST_SUCCESS) {

        //-----------------
        return XST_FAILURE;
    }

    return XST_SUCCESS;
}


#if defined(XPAR_UARTNS550_0_BASEADDR)

//=============================================================================
// UART Setup
//=============================================================================
/* This is only used so the example prints
   predictable text on systems where a
   UART16550-compatible block is present in the
   hardware build. */

static void Uart550_Setup(void)
{
    /* Force a known UART configuration so console
       output is readable and repeatable across
       runs of the example. */
    XUartNs550_SetBaud(
        XPAR_UARTNS550_0_BASEADDR,
        XPAR_XUARTNS550_CLOCK_HZ,
        9600
    );

    XUartNs550_SetLineControlReg(
        XPAR_UARTNS550_0_BASEADDR,
        XUN_LCR_8_DATA_BITS
    );
}

#endif


//=============================================================================
// RX Setup
//=============================================================================
/* This function prepares the S2MM side of the DMA:

   1. Get the RX ring handle.
   2. Disable RX interrupts because this example
      uses polling.
   3. Create the RX BD ring in memory.
   4. Clone a clean BD template across the ring.
   5. Allocate all free RX BDs to software.
   6. Attach receive buffers to those BDs.
   7. Submit those BDs to hardware.
   8. Start the RX ring.

   The important idea is that RX buffers must be
   posted before incoming stream data arrives,
   otherwise the DMA would have nowhere valid to
   write. */

static int RxSetup(XAxiDma *AxiDmaInstPtr)
{
    XAxiDma_BdRing *RxRingPtr;
    int             Delay       = 0;
    int             Coalesce    = 1;
    int             Status;
    XAxiDma_Bd      BdTemplate;
    XAxiDma_Bd     *BdPtr;
    XAxiDma_Bd     *BdCurPtr;
    u32             BdCount;
    u32             FreeBdCount;
    UINTPTR         RxBufferPtr;
    int             Index;

    RxRingPtr = XAxiDma_GetRxRing(AxiDmaInstPtr);

    /* Polling is used in this example, so RX
       interrupts are disabled before the ring is
       configured. */
    XAxiDma_BdRingIntDisable(RxRingPtr, XAXIDMA_IRQ_ALL_MASK);

    /* Set interrupt coalescing parameters even
       though interrupts are off. These fields are
       part of normal ring configuration. */
    XAxiDma_BdRingSetCoalesce(RxRingPtr, Coalesce, Delay);

    /* Compute how many descriptors fit in the
       reserved RX BD memory range, then create
       the RX ring in that memory. */
    BdCount = XAxiDma_BdRingCntCalc(
        XAXIDMA_BD_MINIMUM_ALIGNMENT,
        RX_BD_SPACE_HIGH - RX_BD_SPACE_BASE + 1
    );

    //=================================
    Status = XAxiDma_BdRingCreate(
        RxRingPtr,
        RX_BD_SPACE_BASE,
        RX_BD_SPACE_BASE,
        XAXIDMA_BD_MINIMUM_ALIGNMENT,
        BdCount
    );
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf("RX create BD ring failed %d\r\n", Status);
        //-----------------
        return XST_FAILURE;
    }

    /* Create one clean zeroed descriptor template
       and clone it across the whole ring so every
       descriptor starts from a known state. */
    XAxiDma_BdClear(&BdTemplate);

    //=================================
    Status = XAxiDma_BdRingClone(RxRingPtr, &BdTemplate);
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf("RX clone BD failed %d\r\n", Status);
        //-----------------
        return XST_FAILURE;
    }

    /* Grab all currently free RX descriptors so
       software can fill in buffer addresses and
       lengths for each posted receive buffer. */
    FreeBdCount = XAxiDma_BdRingGetFreeCnt(RxRingPtr);

    //=================================
    Status = XAxiDma_BdRingAlloc(
        RxRingPtr,
        FreeBdCount,
        &BdPtr
    );
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf("RX alloc BD failed %d\r\n", Status);
        //-----------------
        return XST_FAILURE;
    }

    /* Walk through every allocated RX BD and bind
       it to a receive buffer in DDR. Each BD gets:
       - a destination buffer address
       - a maximum transfer length
       - control = 0 for this RX example
       - an ID field used by software bookkeeping */
    BdCurPtr    = BdPtr;
    RxBufferPtr = RX_BUFFER_BASE;

    for (Index = 0; Index < (int)FreeBdCount; Index++) {
        //=================================
        Status = XAxiDma_BdSetBufAddr(BdCurPtr, RxBufferPtr);
        //=================================
        if (Status != XST_SUCCESS) {

            xil_printf(
                "Set buffer addr %x on BD %x failed %d\r\n",
                (unsigned int)RxBufferPtr,
                (UINTPTR)BdCurPtr,
                Status
            );
            //-----------------
            return XST_FAILURE;
        }

        //=================================
        Status = XAxiDma_BdSetLength(
            BdCurPtr,
            MAX_PKT_LEN,
            RxRingPtr->MaxTransferLen
        );
        //=================================
        if (Status != XST_SUCCESS) {

            xil_printf(
                "Rx set length %d on BD %x failed %d\r\n",
                MAX_PKT_LEN,
                (UINTPTR)BdCurPtr,
                Status
            );
            //-----------------
            return XST_FAILURE;
        }

        /* RX descriptors do not manually set
           SOF/EOF control bits here. The hardware
           determines frame boundaries from the
           incoming stream. */
        XAxiDma_BdSetCtrl(BdCurPtr, 0);
        XAxiDma_BdSetId(BdCurPtr, RxBufferPtr);

        RxBufferPtr += MAX_PKT_LEN;
        BdCurPtr     = (XAxiDma_Bd *)XAxiDma_BdRingNext(
            RxRingPtr,
            BdCurPtr
        );
    }

    /* Clear the first receive buffer region
       before the transfer so the demo can later
       verify that fresh data actually arrived. */
    memset((void *)RX_BUFFER_BASE, 0, MAX_PKT_LEN);

    /* Move the prepared RX descriptors from
       software ownership into hardware ownership
       so the DMA can start using them when stream
       data comes in. */
    //=================================
    Status = XAxiDma_BdRingToHw(
        RxRingPtr,
        FreeBdCount,
        BdPtr
    );
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf("RX submit hw failed %d\r\n", Status);
        //-----------------
        return XST_FAILURE;
    }

    /* Start the RX channel after descriptors are
       already posted. This ensures the receive
       side is ready before TX begins. */
    //=================================
    Status = XAxiDma_BdRingStart(RxRingPtr);
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf("RX start hw failed %d\r\n", Status);
        //-----------------
        return XST_FAILURE;
    }

    return XST_SUCCESS;
}


//=============================================================================
// TX Setup
//=============================================================================
/* This function prepares the MM2S side of the DMA:

   1. Get the TX ring handle.
   2. Disable TX interrupts because polling is
      used.
   3. Create the TX BD ring in memory.
   4. Clone a clean BD template across the ring.
   5. Start the TX ring.

   Unlike RX setup, this function does not yet
   attach a real payload buffer. That is done
   later in SendPacket(). */

static int TxSetup(XAxiDma *AxiDmaInstPtr)
{
    XAxiDma_BdRing *TxRingPtr;
    XAxiDma_Bd      BdTemplate;
    int             Delay       = 0;
    int             Coalesce    = 1;
    int             Status;
    u32             BdCount;

    TxRingPtr = XAxiDma_GetTxRing(AxiDmaInstPtr);

    /* Polling mode is used, so TX interrupts are
       disabled before any ring configuration is
       done. */
    XAxiDma_BdRingIntDisable(TxRingPtr, XAXIDMA_IRQ_ALL_MASK);

    /* Configure interrupt coalescing parameters
       as part of normal ring setup. */
    XAxiDma_BdRingSetCoalesce(TxRingPtr, Coalesce, Delay);

    /* Compute how many TX descriptors fit in the
       reserved memory region, then create the TX
       descriptor ring there. */
    BdCount = XAxiDma_BdRingCntCalc(
        XAXIDMA_BD_MINIMUM_ALIGNMENT,
        TX_BD_SPACE_HIGH - TX_BD_SPACE_BASE + 1
    );

    //=================================
    Status = XAxiDma_BdRingCreate(
        TxRingPtr,
        TX_BD_SPACE_BASE,
        TX_BD_SPACE_BASE,
        XAXIDMA_BD_MINIMUM_ALIGNMENT,
        BdCount
    );
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf("failed create BD ring in txsetup\r\n");
        //-----------------
        return XST_FAILURE;
    }

    /* Initialize the entire ring from one clean
       zeroed descriptor template. */
    XAxiDma_BdClear(&BdTemplate);

    //=================================
    Status = XAxiDma_BdRingClone(TxRingPtr, &BdTemplate);
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf("failed bdring clone in txsetup %d\r\n", Status);
        //-----------------
        return XST_FAILURE;
    }

    /* Start the TX ring so later submitted TX BDs
       can be accepted and processed by hardware. */
    //=================================
    Status = XAxiDma_BdRingStart(TxRingPtr);
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf("failed start bdring txsetup %d\r\n", Status);
        //-----------------
        return XST_FAILURE;
    }

    return XST_SUCCESS;
}


//=============================================================================
// SendPacket
//=============================================================================
/* This function submits one transmit packet
   through the TX ring:

   1. Build test data in the TX buffer.
   2. Flush TX and RX buffers for cache
      coherency.
   3. Allocate one TX BD from the free pool.
   4. Fill in buffer address and packet length.
   5. Optionally set application words if that
      feature exists.
   6. Mark the descriptor as both SOF and EOF
      because the whole packet fits in one
      descriptor.
   7. Hand the descriptor to hardware.

   After the final ToHw call, the DMA is free to
   fetch and transmit the data. */

static int SendPacket(XAxiDma *AxiDmaInstPtr)
{
    XAxiDma_BdRing *TxRingPtr;
    u8             *TxPacket;
    u8              Value;
    XAxiDma_Bd     *BdPtr;
    int             Status;
    int             Index;

    TxRingPtr = XAxiDma_GetTxRing(AxiDmaInstPtr);

    /* Fill the TX buffer with a simple
       increasing byte pattern so the RX side can
       later verify the transfer completed
       correctly. */
    TxPacket = (u8 *)Packet;
    Value    = TEST_START_VALUE;

    for (Index = 0; Index < MAX_PKT_LEN; Index++) {
        TxPacket[Index] = Value;
        Value           = (Value + 1) & 0xFF;
    }

    /* Flush the CPU cache lines covering the
       packet buffers so DMA hardware sees the
       latest buffer contents in memory rather
       than stale cache data. */
    Xil_DCacheFlushRange((UINTPTR)TxPacket, MAX_PKT_LEN);
    Xil_DCacheFlushRange((UINTPTR)RX_BUFFER_BASE, MAX_PKT_LEN);

    /* Allocate exactly one TX descriptor because
       this example transmits one packet that fits
       inside a single BD. */
    //=================================
    Status = XAxiDma_BdRingAlloc(TxRingPtr, 1, &BdPtr);
    //=================================
    if (Status != XST_SUCCESS) {

        //-----------------
        return XST_FAILURE;
    }

    /* Bind this descriptor to the TX payload
       buffer in DDR. */
    //=================================
    Status = XAxiDma_BdSetBufAddr(BdPtr, (UINTPTR)Packet);
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf(
            "Tx set buffer addr %x on BD %x failed %d\r\n",
            (UINTPTR)Packet,
            (UINTPTR)BdPtr,
            Status
        );
        //-----------------
        return XST_FAILURE;
    }

    /* Tell the DMA how many bytes to read from
       the TX buffer for this BD. */
    //=================================
    Status = XAxiDma_BdSetLength(
        BdPtr,
        MAX_PKT_LEN,
        TxRingPtr->MaxTransferLen
    );
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf(
            "Tx set length %d on BD %x failed %d\r\n",
            MAX_PKT_LEN,
            (UINTPTR)BdPtr,
            Status
        );
        //-----------------
        return XST_FAILURE;
    }

#ifndef SDT
#if (XPAR_AXIDMA_0_SG_INCLUDE_STSCNTRL_STRM == 1)
    /* If the status/control stream feature
       exists, attach the packet length as an
       application word. This is optional for the
       example. */
    //=================================
    Status = XAxiDma_BdSetAppWord(
        BdPtr,
        XAXIDMA_LAST_APPWORD,
        MAX_PKT_LEN
    );
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf("Set app word failed with %d\r\n", Status);
    }
#endif
#else
    //=================================
    if (TxRingPtr->HasStsCntrlStrm) {

        /* Same optional app-word setup for SDT
           builds when the hardware advertises
           status/control stream support. */
        //=================================
        Status = XAxiDma_BdSetAppWord(
            BdPtr,
            XAXIDMA_LAST_APPWORD,
            MAX_PKT_LEN
        );
        //=================================
        if (Status != XST_SUCCESS) {

            xil_printf("Set app word failed with %d\r\n", Status);
        }
    }
#endif

    /* Because this packet is fully contained
       inside one descriptor, it is both the
       start of frame and the end of frame. */
    XAxiDma_BdSetCtrl(
        BdPtr,
        XAXIDMA_BD_CTRL_TXEOF_MASK |
            XAXIDMA_BD_CTRL_TXSOF_MASK
    );

    /* Store the packet address in the ID field as
       a software tag. */
    XAxiDma_BdSetId(BdPtr, (UINTPTR)Packet);

    /* Hand the prepared TX descriptor to
       hardware. This is the moment the DMA is
       allowed to start reading the buffer and
       transmitting it. */
    //=================================
    Status = XAxiDma_BdRingToHw(TxRingPtr, 1, BdPtr);
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf("to hw failed %d\r\n", Status);
        //-----------------
        return XST_FAILURE;
    }

    return XST_SUCCESS;
}


//=============================================================================
// CheckData
//=============================================================================
/* After RX completes, this function invalidates
   the CPU cache for the receive buffer and then
   checks that the received bytes match the test
   pattern that was originally placed in the TX
   buffer. */

static int CheckData(void)
{
    u8 *RxPacket;
    int Index = 0;
    u8  Value;

    RxPacket = (u8 *)RX_BUFFER_BASE;
    Value    = TEST_START_VALUE;

    /* Invalidate the destination buffer before
       CPU reads it so software sees the data just
       written by the DMA rather than stale cached
       contents. */
    Xil_DCacheInvalidateRange((UINTPTR)RxPacket, MAX_PKT_LEN);

    /* Compare the receive buffer byte-by-byte
       against the known transmitted pattern
       generated earlier in SendPacket(). */
    for (Index = 0; Index < MAX_PKT_LEN; Index++) {
        //=================================
        if (RxPacket[Index] != Value) {

            xil_printf(
                "Data error %d: %x/%x\r\n",
                Index,
                (unsigned int)RxPacket[Index],
                (unsigned int)Value
            );
            //-----------------
            return XST_FAILURE;
        }

        Value = (Value + 1) & 0xFF;
    }

    return XST_SUCCESS;
}


//=============================================================================
// CheckDmaResult
//=============================================================================
/* This function finishes the example by polling
   for completion and cleaning up:

   1. Poll the TX ring until at least one
      processed TX BD is returned.
   2. Free those processed TX BDs back to the
      software free pool.
   3. Poll the RX ring until at least one
      processed RX BD is returned.
   4. Verify the received data.
   5. Free processed RX BDs.
   6. Re-allocate and re-submit RX BDs so the RX
      side is ready again.

   This is the key SG completion pattern:
   FromHw -> inspect/check -> Free -> optionally
   repost for next use */

static int CheckDmaResult(XAxiDma *AxiDmaInstPtr)
{
    XAxiDma_BdRing *TxRingPtr;
    XAxiDma_BdRing *RxRingPtr;
    XAxiDma_Bd     *BdPtr;
    int             ProcessedBdCount;
    int             FreeBdCount;
    int             Status;
    int             TimeOut = POLL_TIMEOUT_COUNTER;

    TxRingPtr = XAxiDma_GetTxRing(AxiDmaInstPtr);
    RxRingPtr = XAxiDma_GetRxRing(AxiDmaInstPtr);

    /* Poll the TX ring until hardware returns at
       least one completed TX BD, or until the
       timeout expires. */
    while (TimeOut) {
        ProcessedBdCount = XAxiDma_BdRingFromHw(
            TxRingPtr,
            XAXIDMA_ALL_BDS,
            &BdPtr
        );

        if (ProcessedBdCount != 0) {
            break;
        }

        TimeOut--;
        usleep(1U);
    }

    /* Once software regains ownership of
       processed TX BDs, return them to the free
       pool so they can be reused by later
       transmissions. */
    //=================================
    Status = XAxiDma_BdRingFree(
        TxRingPtr,
        ProcessedBdCount,
        BdPtr
    );
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf(
            "Failed to free %d tx BDs %d\r\n",
            ProcessedBdCount,
            Status
        );
        //-----------------
        return XST_FAILURE;
    }

    TimeOut = POLL_TIMEOUT_COUNTER;

    /* Poll the RX ring until hardware returns at
       least one completed RX BD, or until the
       timeout expires. */
    while (TimeOut) {
        ProcessedBdCount = XAxiDma_BdRingFromHw(
            RxRingPtr,
            XAXIDMA_ALL_BDS,
            &BdPtr
        );

        if (ProcessedBdCount != 0) {
            break;
        }

        TimeOut--;
        usleep(1U);
    }

    /* The receive descriptors say data has
       arrived, so now verify the actual contents
       of the RX buffer against the expected test
       pattern. */
    //=================================
    if (CheckData() != XST_SUCCESS) {

        //-----------------
        return XST_FAILURE;
    }

    /* Free the processed RX descriptors back into
       the software free pool. */
    //=================================
    Status = XAxiDma_BdRingFree(
        RxRingPtr,
        ProcessedBdCount,
        BdPtr
    );
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf(
            "Failed to free %d rx BDs %d\r\n",
            ProcessedBdCount,
            Status
        );
        //-----------------
        return XST_FAILURE;
    }

    /* Re-post all currently free RX descriptors
       back to hardware so the RX channel is ready
       for another future packet without
       rebuilding the ring. */
    FreeBdCount = XAxiDma_BdRingGetFreeCnt(RxRingPtr);

    //=================================
    Status = XAxiDma_BdRingAlloc(
        RxRingPtr,
        FreeBdCount,
        &BdPtr
    );
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf("bd alloc failed\r\n");
        //-----------------
        return XST_FAILURE;
    }

    //=================================
    Status = XAxiDma_BdRingToHw(
        RxRingPtr,
        FreeBdCount,
        BdPtr
    );
    //=================================
    if (Status != XST_SUCCESS) {

        xil_printf(
            "Submit %d rx BDs failed %d\r\n",
            FreeBdCount,
            Status
        );
        //-----------------
        return XST_FAILURE;
    }

    return XST_SUCCESS;
}