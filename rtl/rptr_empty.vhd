------------------------------------------------------------------------
--
--  $FILENAME    : async_fifo.vhd
--
--  $TITLE       : Asynchronous FIFO read pointer and empty generation
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


ENTITY rptr_empty IS
  GENERIC (
           ADDRSIZE: INTEGER := 4
          );
  PORT (
        rinc, rclk, rrst_n : IN  STD_LOGIC; 
        rq2_wptr           : IN  STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0);
        rempty             : OUT STD_LOGIC; 
        raddr              : OUT STD_LOGIC_VECTOR(ADDRSIZE-1 DOWNTO 0);
        rptr               : OUT STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0)
       );
END ENTITY rptr_empty;


ARCHITECTURE RTL OF rptr_empty IS

SIGNAL rbin                 : STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0) := (OTHERS => '0');
SIGNAL inc_rbin             : STD_LOGIC := '0';
SIGNAL rgraynext, rbinnext  : STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0) := (OTHERS => '0');
SIGNAL rempty_i, rempty_val : STD_LOGIC := '0';

BEGIN
  
  -- GRAYSTYLE2 pointer process
  GRAYSTYLE2_PROC: PROCESS (rclk)
  BEGIN
    IF (rclk'EVENT AND rclk = '1') THEN
      IF (rrst_n = '0') THEN
        rbin <= (OTHERS => '0');
        rptr <= (OTHERS => '0');
      ELSE
        rbin <= rbin + inc_rbin;
        rptr <= rgraynext;
      END IF;
    END IF;
  END PROCESS GRAYSTYLE2_PROC;

  COMB_PROC: PROCESS (rbin, rinc, rempty_i, inc_rbin, rbinnext)
  BEGIN
    inc_rbin  <= rinc AND (NOT rempty_i);
    rbinnext  <= rbin + inc_rbin;
    rgraynext <= ('0' & rbinnext(ADDRSIZE DOWNTO 1)) XOR rbinnext;
  END PROCESS COMB_PROC;

  -- Memory read-address pointer (okay to use binary to address memory)
  raddr     <= rbin(ADDRSIZE-1 DOWNTO 0);
  -- FIFO empty when the next rptr == synchronized wptr or on reset
  rempty_val <= '1' when rgraynext = rq2_wptr else
                '0';

  -- FIFO empty process
  EMPTY_PROC: PROCESS (rclk)
  BEGIN
    IF (rclk'EVENT AND rclk = '1') THEN
      IF (rrst_n = '0') THEN
        rempty_i <= '0';
      ELSE
        rempty_i <= rempty_val;
      END IF;
    END IF;
  END PROCESS EMPTY_PROC;
  
  rempty <= rempty_i;

END ARCHITECTURE RTL;
