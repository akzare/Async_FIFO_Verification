------------------------------------------------------------------------
--
--  $FILENAME    : async_fifo.vhd
--
--  $TITLE       : Asynchronous FIFO module (Top level wrapper)
--
--  $DATE        : 13 Nov 2017
--
--  $VERSION     : 1.0.0
--
--  $DESCRIPTION : This module implements an asynchronous FIFO. This code
--                 is created based on a Systemverilog code from Jason Yu
--                 http://www.verilogpro.com/asynchronous-fifo-design/
--
--  $AUTHOR     : Armin Zare Zadeh (ali.a.zarezadeh @ gmail.com)
------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY async_fifo IS
  GENERIC (
           DSIZE: INTEGER := 8;
           ASIZE: INTEGER := 4
          );
  PORT (
        winc, wclk, wrst_n: IN  STD_LOGIC;
        rinc, rclk, rrst_n: IN  STD_LOGIC;
        wdata:              IN  STD_LOGIC_VECTOR(DSIZE-1 DOWNTO 0);

        rdata:              OUT STD_LOGIC_VECTOR(DSIZE-1 DOWNTO 0);
        wfull:              OUT STD_LOGIC;
        rempty:             OUT STD_LOGIC
       );
END ENTITY async_fifo;


ARCHITECTURE TOP_HIER OF async_fifo IS

  -------------------------------
  -- Signals definitions
  -------------------------------

  SIGNAL waddr, raddr                   : STD_LOGIC_VECTOR(ASIZE-1 DOWNTO 0);
  SIGNAL wptr, rptr, wq2_rptr, rq2_wptr : STD_LOGIC_VECTOR(ASIZE DOWNTO 0);
  SIGNAL wfull_i, rempty_i              : STD_LOGIC;

  -------------------------------
  -- Components declartion
  -------------------------------

  COMPONENT sync_r2w IS
    GENERIC (
             ADDRSIZE: INTEGER
            );
    PORT (
          wclk, wrst_n : IN  STD_LOGIC;
          rptr         : IN  STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0);
          wq2_rptr     : OUT STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0)
         );
  END COMPONENT sync_r2w;


  COMPONENT sync_w2r IS
    GENERIC (
             ADDRSIZE: INTEGER
            );
    PORT (
          rclk, rrst_n : IN  STD_LOGIC;
          wptr         : IN  STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0);
          rq2_wptr     : OUT STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0)
         );
  END COMPONENT sync_w2r;


  COMPONENT fifomem IS
    GENERIC (
             DATASIZE: INTEGER;
             ADDRSIZE: INTEGER
            );
    PORT (
          winc, wfull, wclk  : IN  STD_LOGIC;
          rinc, rempty, rclk : IN  STD_LOGIC;
          waddr, raddr       : IN  STD_LOGIC_VECTOR(ADDRSIZE-1 DOWNTO 0);
          wdata              : IN  STD_LOGIC_VECTOR(DATASIZE-1 DOWNTO 0);
          rdata              : OUT STD_LOGIC_VECTOR(DATASIZE-1 DOWNTO 0)
         );
  END COMPONENT fifomem;


  COMPONENT rptr_empty IS
    GENERIC (
             ADDRSIZE: INTEGER
            );
    PORT (
          rinc, rclk, rrst_n : IN  STD_LOGIC; 
          rq2_wptr           : IN  STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0);
          rempty             : OUT STD_LOGIC;
          raddr              : OUT STD_LOGIC_VECTOR(ADDRSIZE-1 DOWNTO 0);
          rptr               : OUT STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0)
         );
  END COMPONENT rptr_empty;


  COMPONENT wptr_full IS
    GENERIC (
             ADDRSIZE: INTEGER := 4
            );
    PORT (
          winc, wclk, wrst_n : IN  STD_LOGIC; 
          wq2_rptr           : IN  STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0);
          wfull              : OUT STD_LOGIC; 
          waddr              : OUT STD_LOGIC_VECTOR(ADDRSIZE-1 DOWNTO 0);
          wptr               : OUT STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0)
         );
  END COMPONENT wptr_full;


BEGIN

  -------------------------------
  -- Components instantiation
  -------------------------------

  -- Instantiate sync_r2w
  sync_r2w_inst : sync_r2w
    GENERIC MAP (
                 ADDRSIZE => ASIZE
                )
    PORT MAP (
              wclk     => wclk,
              wrst_n   => wrst_n,
              rptr     => rptr,
              wq2_rptr => wq2_rptr
            );


  -- Instantiate sync_w2r
  sync_w2r_inst : sync_w2r
    GENERIC MAP (
                 ADDRSIZE => ASIZE
                )
    PORT MAP (
              rclk     => rclk,
              rrst_n   => rrst_n,
              wptr     => wptr,
              rq2_wptr => rq2_wptr
             );


  -- Instantiate fifomem
  fifomem_inst : fifomem
    GENERIC MAP (
                 DATASIZE => DSIZE, 
                 ADDRSIZE => ASIZE
                )
    PORT MAP (
              winc   => winc,
              wfull  => wfull_i,
              wclk   => wclk,
              rinc   => rinc,
              rempty => rempty_i,
              rclk   => rclk,
              waddr  => waddr,
              raddr  => raddr,
              wdata  => wdata,
              rdata  => rdata
             );


  -- Instantiate rptr_empty
  rptr_empty_inst : rptr_empty
    GENERIC MAP (
                 ADDRSIZE => ASIZE
                )
    PORT MAP (
               rinc     => rinc,
               rclk     => rclk,
               rrst_n   => rrst_n,
               rq2_wptr => rq2_wptr,
               rempty   => rempty_i,
               raddr    => raddr,
               rptr     => rptr
             );


  -- Instantiate wptr_full
  wptr_full_inst : wptr_full
    GENERIC MAP (
                 ADDRSIZE => ASIZE
                )
    PORT MAP (
               winc     => winc,
               wclk     => wclk,
               wrst_n   => wrst_n,
               wq2_rptr => wq2_rptr,
               wfull    => wfull_i,
               waddr    => waddr,
               wptr     => wptr
             );

  wfull  <= wfull_i;
  rempty <= rempty_i;

END ARCHITECTURE TOP_HIER;
