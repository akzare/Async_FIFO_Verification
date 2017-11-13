------------------------------------------------------------------------
--
--  $FILENAME    : async_fifo.vhd
--
--  $TITLE       : Asynchronous FIFO write pointer and full generation
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


ENTITY wptr_full IS
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
       
END ENTITY wptr_full;



ARCHITECTURE RTL OF wptr_full IS

SIGNAL wbin                : STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0) := (OTHERS => '0');
SIGNAL inc_wbin            : STD_LOGIC := '0';
SIGNAL wgraynext, wbinnext : STD_LOGIC_VECTOR(ADDRSIZE DOWNTO 0) := (OTHERS => '0');
SIGNAL wfull_i, wfull_val  : STD_LOGIC := '0';

BEGIN
  
  -- GRAYSTYLE2 pointer process
  GRAYSTYLE2_PROC: PROCESS (wclk)
  BEGIN
    IF (wclk'EVENT AND wclk = '1') THEN
      IF (wrst_n = '0') THEN
        wbin <= (OTHERS => '0');
        wptr <= (OTHERS => '0');
      ELSE
        wbin <= wbin + inc_wbin;
        wptr <= wgraynext;
      END IF;
    END IF;
  END PROCESS GRAYSTYLE2_PROC;

  COMB_PROC: PROCESS (wbin, winc, wfull_i, inc_wbin, wbinnext)
  BEGIN
    inc_wbin  <= winc AND (NOT wfull_i);
    wbinnext  <= wbin + inc_wbin;
    wgraynext <= ('0' & wbinnext(ADDRSIZE DOWNTO 1)) XOR wbinnext;
  END PROCESS COMB_PROC;

  -- Memory write-address pointer (okay to use binary to address memory)
  waddr     <= wbin(ADDRSIZE-1 DOWNTO 0);
  -- FIFO empty when the next rptr == synchronized wptr or on reset
  wfull_val <= '1' when (wgraynext(ADDRSIZE)           /= wq2_rptr(ADDRSIZE)   AND 
                         wgraynext(ADDRSIZE-1)         /= wq2_rptr(ADDRSIZE-1) AND 
                         wgraynext(ADDRSIZE-2 DOWNTO 0) = wq2_rptr(ADDRSIZE-2 DOWNTO 0)) ELSE
                '0';

  -- FIFO full process
  FULL_PROC: PROCESS (wclk)
  BEGIN
    IF (wclk'EVENT AND wclk = '1') THEN
      IF (wrst_n = '0') THEN
        wfull_i <= '0';
      ELSE
        wfull_i <= wfull_val;
      END IF;
    END IF;
  END PROCESS FULL_PROC;

  wfull <= wfull_i;

END ARCHITECTURE RTL;
