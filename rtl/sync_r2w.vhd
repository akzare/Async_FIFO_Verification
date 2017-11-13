------------------------------------------------------------------------
--
--  $FILENAME    : async_fifo.vhd
--
--  $TITLE       : Asynchronous FIFO read pointer to write clock synchronizer
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
use ieee.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY sync_r2w IS
  GENERIC (
           ADDRSIZE: INTEGER := 4
          );
  PORT (
        wclk, wrst_n : IN  STD_LOGIC; 
        rptr         : IN  STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0);
        wq2_rptr     : OUT STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0)
       );
END ENTITY sync_r2w;


ARCHITECTURE RTL OF sync_r2w IS

SIGNAL wq1_rptr : STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0) := (OTHERS => '0');

BEGIN
  
  -- Synchronizer process
  SYNC_PROC: PROCESS (wclk)
  BEGIN
    IF (wclk'EVENT AND wclk = '1') THEN
      IF (wrst_n = '0') THEN
        wq2_rptr <= (OTHERS => '0');
        wq1_rptr <= (OTHERS => '0');
      ELSE
        wq2_rptr <= wq1_rptr;
        wq1_rptr <= rptr;
      END IF;
    END IF;
  END PROCESS SYNC_PROC;

END ARCHITECTURE RTL;

