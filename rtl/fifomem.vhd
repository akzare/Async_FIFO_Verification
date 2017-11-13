------------------------------------------------------------------------
--
--  $FILENAME    : async_fifo.vhd
--
--  $TITLE       : FIFO memory
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
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY fifomem IS
  GENERIC (
           DATASIZE: INTEGER := 8;
           ADDRSIZE: INTEGER := 4
          );
  PORT (
        winc, wfull, wclk  : IN  STD_LOGIC; 
        rinc, rempty, rclk : IN  STD_LOGIC;
        waddr, raddr       : IN  STD_LOGIC_VECTOR(ADDRSIZE-1 DOWNTO 0);
        wdata              : IN  STD_LOGIC_VECTOR(DATASIZE-1 DOWNTO 0);
        rdata              : OUT STD_LOGIC_VECTOR(DATASIZE-1 DOWNTO 0)
       );
END ENTITY fifomem;


ARCHITECTURE BEHAV OF fifomem IS

CONSTANT DEPTH : INTEGER := INTEGER(2**ADDRSIZE);

TYPE ram_type IS ARRAY (DEPTH-1 DOWNTO 0) OF STD_LOGIC_VECTOR(DATASIZE-1 DOWNTO 0);
SIGNAL mem : ram_type := (OTHERS => (OTHERS => '0'));


BEGIN

  -- Async Read
  rdata <= mem(CONV_INTEGER(raddr));
  
  -- Sync Read functional process
--  READ_PROC: PROCESS (rclk)
--  BEGIN
--    IF (rclk'EVENT AND rclk = '1') THEN
--      IF (rinc = '1' AND rempty = '0') THEN
--        rdata <= mem(CONV_INTEGER(raddr));
--      ELSE
--        rdata <= (rdata'RANGE => 'Z');
--      END IF;
--    END IF;
--  END PROCESS READ_PROC;

  -- Sync Write functional process
  WRITE_PROC: PROCESS (wclk)
  BEGIN
    IF (wclk'EVENT AND wclk = '1') THEN
      IF (winc = '1' AND wfull = '0') THEN
        mem(CONV_INTEGER(waddr)) <= wdata;
      END IF;
    END IF;
  END PROCESS WRITE_PROC;

END ARCHITECTURE BEHAV;
