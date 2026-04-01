module dma_bram_loopback #(
    parameter int DATA_W = 256,
    parameter int ADDR_W = 10
) (
    input  logic                   clk,
    input  logic                   rst_n,


    //-----------------
    // AXI-Stream slave side
    // from AXI DMA M_AXIS_MM2S
    //-----------------
    input  logic [DATA_W-1:0]      s_axis_tdata,
    input  logic [(DATA_W/8)-1:0]  s_axis_tkeep,
    input  logic                   s_axis_tvalid,
    output logic                   s_axis_tready,
    input  logic                   s_axis_tlast,


    //-----------------
    // AXI-Stream master side
    // to AXI DMA S_AXIS_S2MM
    //-----------------
    output logic [DATA_W-1:0]      m_axis_tdata,
    output logic [(DATA_W/8)-1:0]  m_axis_tkeep,
    output logic                   m_axis_tvalid,
    input  logic                   m_axis_tready,
    output logic                   m_axis_tlast,


    //-----------------
    // Native BRAM port A
    // write port
    //-----------------
    output logic                   bram_ena,
    output logic [0:0]             bram_wea,
    output logic [ADDR_W-1:0]      bram_addra,
    output logic [DATA_W-1:0]      bram_dina,


    //-----------------
    // Native BRAM port B
    // read port
    //-----------------
    output logic                   bram_enb,
    output logic [ADDR_W-1:0]      bram_addrb,
    input  logic [DATA_W-1:0]      bram_doutb
);


    //-----------------
    // State encoding
    //-----------------
    typedef enum logic [2:0] {
        ST_IDLE,
        ST_RECV,
        ST_SEND_REQ,
        ST_SEND_WAIT,
        ST_SEND_DATA
    } state_t;

    state_t state;


    //-----------------
    // Internal registers
    //-----------------
    logic [ADDR_W-1:0] wr_addr;
    logic [ADDR_W-1:0] rd_addr;
    logic [ADDR_W-1:0] frame_words;
    logic [ADDR_W-1:0] send_index;

    logic              s_fire;
    logic              m_fire;
    logic              send_last_word;


    //-----------------
    // Handshake helpers
    //-----------------
    assign s_fire = s_axis_tvalid && s_axis_tready;
    assign m_fire = m_axis_tvalid && m_axis_tready;


    //-----------------
    // Receive side
    //-----------------
    assign s_axis_tready = (state == ST_IDLE) || (state == ST_RECV);


    //-----------------
    // BRAM write side
    // write one word on each input handshake
    //-----------------
    assign bram_ena   = s_fire;
    assign bram_wea   = s_fire ? 1'b1 : 1'b0;
    assign bram_addra = wr_addr;
    assign bram_dina  = s_axis_tdata;


    //-----------------
    // BRAM read side
    // ST_SEND_REQ issues the read
    // ST_SEND_WAIT accounts for 1-cycle BRAM read latency
    //-----------------
    assign bram_enb   = (state == ST_SEND_REQ);
    assign bram_addrb = rd_addr;


    //-----------------
    // Send side
    // bram_doutb is used after the 1-cycle read latency
    //-----------------
    assign m_axis_tdata  = bram_doutb;
    assign m_axis_tkeep  = '1;
    assign m_axis_tvalid = (state == ST_SEND_DATA);

    assign send_last_word = (send_index == (frame_words - 1'b1));
    assign m_axis_tlast   = (state == ST_SEND_DATA) && send_last_word;


    //-----------------
    // Main FSM
    //-----------------
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state       <= ST_IDLE;

            wr_addr     <= '0;
            rd_addr     <= '0;
            frame_words <= '0;
            send_index  <= '0;
        end
        else begin
            case (state)

                //-----------------
                // Wait for first input beat
                //-----------------
                ST_IDLE: begin
                    wr_addr     <= '0;
                    rd_addr     <= '0;
                    frame_words <= '0;
                    send_index  <= '0;

                    if (s_fire) begin
                        if (s_axis_tlast) begin
                            frame_words <= {{(ADDR_W-1){1'b0}}, 1'b1};
                            rd_addr     <= '0;
                            send_index  <= '0;
                            state       <= ST_SEND_REQ;
                        end
                        else begin
                            wr_addr <= wr_addr + 1'b1;
                            state   <= ST_RECV;
                        end
                    end
                end


                //-----------------
                // Receive words until first TLAST
                //-----------------
                ST_RECV: begin
                    if (s_fire) begin
                        if (s_axis_tlast) begin
                            frame_words <= wr_addr + 1'b1;
                            rd_addr     <= '0;
                            send_index  <= '0;
                            state       <= ST_SEND_REQ;
                        end
                        else begin
                            wr_addr <= wr_addr + 1'b1;
                        end
                    end
                end


                //-----------------
                // Issue BRAM read request
                //-----------------
                ST_SEND_REQ: begin
                    state <= ST_SEND_WAIT;
                end


                //-----------------
                // Wait 1 clock for BRAM read data
                //-----------------
                ST_SEND_WAIT: begin
                    state <= ST_SEND_DATA;
                end


                //-----------------
                // Drive one output beat
                //-----------------
                ST_SEND_DATA: begin
                    if (m_fire) begin
                        if (send_last_word) begin
                            state <= ST_IDLE;
                        end
                        else begin
                            rd_addr    <= rd_addr + 1'b1;
                            send_index <= send_index + 1'b1;
                            state      <= ST_SEND_REQ;
                        end
                    end
                end


                //-----------------
                // Default recovery
                //-----------------
                default: begin
                    state <= ST_IDLE;
                end

            endcase
        end
    end


endmodule