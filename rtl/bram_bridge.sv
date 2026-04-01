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


    //-----------------
    // Registered state/data
    //-----------------
    state_t            state_q,       state_d;
    logic [ADDR_W-1:0] wr_addr_q,     wr_addr_d;
    logic [ADDR_W-1:0] rd_addr_q,     rd_addr_d;
    logic [ADDR_W-1:0] frame_words_q, frame_words_d;
    logic [ADDR_W-1:0] send_index_q,  send_index_d;


    //-----------------
    // Handshake helpers
    //-----------------
    logic s_fire;
    logic m_fire;
    logic last_send_word;


    //-----------------
    // Output defaults / next outputs
    //-----------------
    logic                   s_axis_tready_n;

    logic [DATA_W-1:0]      m_axis_tdata_n;
    logic [(DATA_W/8)-1:0]  m_axis_tkeep_n;
    logic                   m_axis_tvalid_n;
    logic                   m_axis_tlast_n;

    logic                   bram_ena_n;
    logic [0:0]             bram_wea_n;
    logic [ADDR_W-1:0]      bram_addra_n;
    logic [DATA_W-1:0]      bram_dina_n;

    logic                   bram_enb_n;
    logic [ADDR_W-1:0]      bram_addrb_n;


    //-----------------
    // Continuous combinational helpers
    //-----------------
    assign s_fire = s_axis_tvalid && s_axis_tready;
    assign m_fire = m_axis_tvalid && m_axis_tready;


    //-----------------
    // Helper combinational logic
    //-----------------
    always_comb begin
        last_send_word = 1'b0;

        if (frame_words_q != '0) begin
            last_send_word = (send_index_q == (frame_words_q - 1'b1));
        end
    end


    //-----------------
    // Output combinational logic
    //-----------------
    always_comb begin
        s_axis_tready_n = 1'b0;

        m_axis_tdata_n  = bram_doutb;
        m_axis_tkeep_n  = '0;
        m_axis_tvalid_n = 1'b0;
        m_axis_tlast_n  = 1'b0;

        bram_ena_n      = 1'b0;
        bram_wea_n      = 1'b0;
        bram_addra_n    = wr_addr_q;
        bram_dina_n     = s_axis_tdata;

        bram_enb_n      = 1'b0;
        bram_addrb_n    = rd_addr_q;

        case (state_q)

            ST_IDLE: begin
                s_axis_tready_n = 1'b1;

                if (s_axis_tvalid) begin
                    bram_ena_n   = 1'b1;
                    bram_wea_n   = 1'b1;
                    bram_addra_n = '0;
                    bram_dina_n  = s_axis_tdata;
                end
            end


            ST_RECV: begin
                s_axis_tready_n = 1'b1;

                if (s_axis_tvalid) begin
                    bram_ena_n   = 1'b1;
                    bram_wea_n   = 1'b1;
                    bram_addra_n = wr_addr_q;
                    bram_dina_n  = s_axis_tdata;
                end
            end


            ST_SEND_REQ: begin
                bram_enb_n   = 1'b1;
                bram_addrb_n = rd_addr_q;
            end


            ST_SEND_WAIT: begin
                // no output action needed here
            end


            ST_SEND_DATA: begin
                m_axis_tdata_n  = bram_doutb;
                m_axis_tkeep_n  = '1;
                m_axis_tvalid_n = 1'b1;
                m_axis_tlast_n  = last_send_word;
            end


            default: begin
                // keep defaults
            end

        endcase
    end


    //-----------------
    // Drive outputs
    //-----------------
    always_comb begin
        s_axis_tready = s_axis_tready_n;

        m_axis_tdata  = m_axis_tdata_n;
        m_axis_tkeep  = m_axis_tkeep_n;
        m_axis_tvalid = m_axis_tvalid_n;
        m_axis_tlast  = m_axis_tlast_n;

        bram_ena      = bram_ena_n;
        bram_wea      = bram_wea_n;
        bram_addra    = bram_addra_n;
        bram_dina     = bram_dina_n;

        bram_enb      = bram_enb_n;
        bram_addrb    = bram_addrb_n;
    end


    //-----------------
    // Next-state / next-register combinational logic
    //-----------------
    always_comb begin
        state_d       = state_q;
        wr_addr_d     = wr_addr_q;
        rd_addr_d     = rd_addr_q;
        frame_words_d = frame_words_q;
        send_index_d  = send_index_q;

        case (state_q)

            ST_IDLE: begin
                wr_addr_d     = '0;
                rd_addr_d     = '0;
                frame_words_d = '0;
                send_index_d  = '0;

                if (s_fire) begin
                    if (s_axis_tlast) begin
                        frame_words_d = {{(ADDR_W-1){1'b0}}, 1'b1};
                        rd_addr_d     = '0;
                        send_index_d  = '0;
                        state_d       = ST_SEND_REQ;
                    end
                    else begin
                        wr_addr_d = {{(ADDR_W-1){1'b0}}, 1'b1};
                        state_d   = ST_RECV;
                    end
                end
            end


            ST_RECV: begin
                if (s_fire) begin
                    if (s_axis_tlast) begin
                        frame_words_d = wr_addr_q + 1'b1;
                        rd_addr_d     = '0;
                        send_index_d  = '0;
                        state_d       = ST_SEND_REQ;
                    end
                    else begin
                        wr_addr_d = wr_addr_q + 1'b1;
                    end
                end
            end


            ST_SEND_REQ: begin
                state_d = ST_SEND_WAIT;
            end


            ST_SEND_WAIT: begin
                state_d = ST_SEND_DATA;
            end


            ST_SEND_DATA: begin
                if (m_fire) begin
                    if (last_send_word) begin
                        state_d = ST_IDLE;
                    end
                    else begin
                        rd_addr_d    = rd_addr_q + 1'b1;
                        send_index_d = send_index_q + 1'b1;
                        state_d      = ST_SEND_REQ;
                    end
                end
            end


            default: begin
                state_d = ST_IDLE;
            end

        endcase
    end


    //-----------------
    // Sequential register update only
    //-----------------
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state_q       <= ST_IDLE;
            wr_addr_q     <= '0;
            rd_addr_q     <= '0;
            frame_words_q <= '0;
            send_index_q  <= '0;
        end
        else begin
            state_q       <= state_d;
            wr_addr_q     <= wr_addr_d;
            rd_addr_q     <= rd_addr_d;
            frame_words_q <= frame_words_d;
            send_index_q  <= send_index_d;
        end
    end


endmodule