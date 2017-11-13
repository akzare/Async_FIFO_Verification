------------------------------------------------------------------------
--
--  $FILENAME    : async_fifo.vhd
--
--  $TITLE       : Asynchronous FIFO write pointer to read clock synchronizer
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


ENTITY sync_w2r IS
  GENERIC (
           ADDRSIZE: INTEGER := 4
          );
  PORT (
        rclk, rrst_n : IN  STD_LOGIC; 
        wptr         : IN  STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0);
        rq2_wptr     : OUT STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0)
       );
END ENTITY sync_w2r;


ARCHITECTURE RTL OF sync_w2r IS

SIGNAL rq1_wptr : STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0) := (OTHERS => '0');


BEGIN
  
  -- Synchronizer process
  SYNC_PROC: PROCESS (rclk)
  BEGIN
    IF (rclk'EVENT AND rclk = '1') THEN
      IF (rrst_n = '0') THEN
        rq2_wptr <= (OTHERS => '0');
        rq1_wptr <= (OTHERS => '0');
      ELSE
        rq2_wptr <= rq1_wptr;
        rq1_wptr <= wptr;
      END IF;
    END IF;
  END PROCESS SYNC_PROC;

END ARCHITECTURE RTL;

