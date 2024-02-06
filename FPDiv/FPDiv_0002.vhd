-- ------------------------------------------------------------------------- 
-- High Level Design Compiler for Intel(R) FPGAs Version 18.1 (Release Build #625)
-- Quartus Prime development tool and MATLAB/Simulink Interface
-- 
-- Legal Notice: Copyright 2018 Intel Corporation.  All rights reserved.
-- Your use of  Intel Corporation's design tools,  logic functions and other
-- software and  tools, and its AMPP partner logic functions, and any output
-- files any  of the foregoing (including  device programming  or simulation
-- files), and  any associated  documentation  or information  are expressly
-- subject  to the terms and  conditions of the  Intel FPGA Software License
-- Agreement, Intel MegaCore Function License Agreement, or other applicable
-- license agreement,  including,  without limitation,  that your use is for
-- the  sole  purpose of  programming  logic devices  manufactured by  Intel
-- and  sold by Intel  or its authorized  distributors. Please refer  to the
-- applicable agreement for further details.
-- ---------------------------------------------------------------------------

-- VHDL created from FPDiv_0002
-- VHDL created on Tue Feb 06 14:51:09 2024


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;
use std.TextIO.all;
use work.dspba_library_package.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity FPDiv_0002 is
    port (
        a : in std_logic_vector(15 downto 0);  -- float16_m10
        b : in std_logic_vector(15 downto 0);  -- float16_m10
        en : in std_logic_vector(0 downto 0);  -- ufix1
        q : out std_logic_vector(15 downto 0);  -- float16_m10
        clk : in std_logic;
        areset : in std_logic
    );
end FPDiv_0002;

architecture normal of FPDiv_0002 is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal GND_q : STD_LOGIC_VECTOR (0 downto 0);
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cstBiasM1_uid6_fpDivTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal expX_uid9_fpDivTest_b : STD_LOGIC_VECTOR (4 downto 0);
    signal fracX_uid10_fpDivTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal signX_uid11_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal expY_uid12_fpDivTest_b : STD_LOGIC_VECTOR (4 downto 0);
    signal fracY_uid13_fpDivTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal signY_uid14_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal paddingY_uid15_fpDivTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal updatedY_uid16_fpDivTest_q : STD_LOGIC_VECTOR (10 downto 0);
    signal fracYZero_uid15_fpDivTest_a : STD_LOGIC_VECTOR (10 downto 0);
    signal fracYZero_uid15_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracYZero_uid15_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cstAllOWE_uid18_fpDivTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal cstAllZWE_uid20_fpDivTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal excZ_x_uid23_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_x_uid23_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid24_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid24_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid25_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid25_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid26_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_x_uid27_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_x_uid28_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid29_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid30_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_x_uid31_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_y_uid37_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_y_uid37_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid38_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid38_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid39_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid39_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid40_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_y_uid41_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_y_uid42_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid43_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid44_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_y_uid45_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signR_uid46_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal signR_uid46_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXmY_uid47_fpDivTest_a : STD_LOGIC_VECTOR (5 downto 0);
    signal expXmY_uid47_fpDivTest_b : STD_LOGIC_VECTOR (5 downto 0);
    signal expXmY_uid47_fpDivTest_o : STD_LOGIC_VECTOR (5 downto 0);
    signal expXmY_uid47_fpDivTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal expR_uid48_fpDivTest_a : STD_LOGIC_VECTOR (7 downto 0);
    signal expR_uid48_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal expR_uid48_fpDivTest_o : STD_LOGIC_VECTOR (7 downto 0);
    signal expR_uid48_fpDivTest_q : STD_LOGIC_VECTOR (6 downto 0);
    signal yAddr_uid51_fpDivTest_b : STD_LOGIC_VECTOR (6 downto 0);
    signal yPE_uid52_fpDivTest_b : STD_LOGIC_VECTOR (2 downto 0);
    signal fracYPostZ_uid56_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracYPostZ_uid56_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal lOAdded_uid58_fpDivTest_q : STD_LOGIC_VECTOR (10 downto 0);
    signal oFracXSE_bottomExtension_uid61_fpDivTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal oFracXSE_mergedSignalTM_uid63_fpDivTest_q : STD_LOGIC_VECTOR (12 downto 0);
    signal divValPreNormS_uid65_fpDivTest_b : STD_LOGIC_VECTOR (12 downto 0);
    signal divValPreNormTrunc_uid66_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal divValPreNormTrunc_uid66_fpDivTest_q : STD_LOGIC_VECTOR (12 downto 0);
    signal norm_uid67_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal divValPreNormHigh_uid68_fpDivTest_in : STD_LOGIC_VECTOR (11 downto 0);
    signal divValPreNormHigh_uid68_fpDivTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal divValPreNormLow_uid69_fpDivTest_in : STD_LOGIC_VECTOR (10 downto 0);
    signal divValPreNormLow_uid69_fpDivTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal normFracRnd_uid70_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal normFracRnd_uid70_fpDivTest_q : STD_LOGIC_VECTOR (10 downto 0);
    signal expFracRnd_uid71_fpDivTest_q : STD_LOGIC_VECTOR (17 downto 0);
    signal rndOp_uid75_fpDivTest_q : STD_LOGIC_VECTOR (11 downto 0);
    signal expFracPostRnd_uid76_fpDivTest_a : STD_LOGIC_VECTOR (19 downto 0);
    signal expFracPostRnd_uid76_fpDivTest_b : STD_LOGIC_VECTOR (19 downto 0);
    signal expFracPostRnd_uid76_fpDivTest_o : STD_LOGIC_VECTOR (19 downto 0);
    signal expFracPostRnd_uid76_fpDivTest_q : STD_LOGIC_VECTOR (18 downto 0);
    signal fracRPreExc_uid78_fpDivTest_in : STD_LOGIC_VECTOR (10 downto 0);
    signal fracRPreExc_uid78_fpDivTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal excRPreExc_uid79_fpDivTest_in : STD_LOGIC_VECTOR (15 downto 0);
    signal excRPreExc_uid79_fpDivTest_b : STD_LOGIC_VECTOR (4 downto 0);
    signal expRExt_uid80_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal expUdf_uid81_fpDivTest_a : STD_LOGIC_VECTOR (9 downto 0);
    signal expUdf_uid81_fpDivTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal expUdf_uid81_fpDivTest_o : STD_LOGIC_VECTOR (9 downto 0);
    signal expUdf_uid81_fpDivTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal expOvf_uid84_fpDivTest_a : STD_LOGIC_VECTOR (9 downto 0);
    signal expOvf_uid84_fpDivTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal expOvf_uid84_fpDivTest_o : STD_LOGIC_VECTOR (9 downto 0);
    signal expOvf_uid84_fpDivTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal zeroOverReg_uid85_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal regOverRegWithUf_uid86_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal xRegOrZero_uid87_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal regOrZeroOverInf_uid88_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRZero_uid89_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXRYZ_uid90_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXRYROvf_uid91_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYZ_uid92_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYR_uid93_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInf_uid94_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXZYZ_uid95_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYI_uid96_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaN_uid97_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal concExc_uid98_fpDivTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal excREnc_uid99_fpDivTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal oneFracRPostExc2_uid100_fpDivTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal fracRPostExc_uid103_fpDivTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPostExc_uid103_fpDivTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal expRPostExc_uid107_fpDivTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal expRPostExc_uid107_fpDivTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal invExcRNaN_uid108_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal sRPostExc_uid109_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal divR_uid110_fpDivTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal rndBit_uid122_invPolyEval_q : STD_LOGIC_VECTOR (2 downto 0);
    signal cIncludingRoundingBit_uid123_invPolyEval_q : STD_LOGIC_VECTOR (20 downto 0);
    signal ts1_uid125_invPolyEval_a : STD_LOGIC_VECTOR (21 downto 0);
    signal ts1_uid125_invPolyEval_b : STD_LOGIC_VECTOR (21 downto 0);
    signal ts1_uid125_invPolyEval_o : STD_LOGIC_VECTOR (21 downto 0);
    signal ts1_uid125_invPolyEval_q : STD_LOGIC_VECTOR (21 downto 0);
    signal s1_uid126_invPolyEval_b : STD_LOGIC_VECTOR (20 downto 0);
    signal topRangeX_mergedSignalTM_uid144_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (17 downto 0);
    signal topRangeY_bottomExtension_uid146_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (6 downto 0);
    signal topRangeY_mergedSignalTM_uid148_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (17 downto 0);
    signal sm0_uid150_prodDivPreNormProd_uid60_fpDivTest_a0 : STD_LOGIC_VECTOR (17 downto 0);
    signal sm0_uid150_prodDivPreNormProd_uid60_fpDivTest_b0 : STD_LOGIC_VECTOR (17 downto 0);
    signal sm0_uid150_prodDivPreNormProd_uid60_fpDivTest_s1 : STD_LOGIC_VECTOR (35 downto 0);
    signal sm0_uid150_prodDivPreNormProd_uid60_fpDivTest_reset : std_logic;
    signal sm0_uid150_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal osig_uid151_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (13 downto 0);
    signal nx_mergedSignalTM_uid155_pT1_uid121_invPolyEval_q : STD_LOGIC_VECTOR (3 downto 0);
    signal topRangeX_bottomExtension_uid162_pT1_uid121_invPolyEval_q : STD_LOGIC_VECTOR (3 downto 0);
    signal topRangeX_mergedSignalTM_uid164_pT1_uid121_invPolyEval_q : STD_LOGIC_VECTOR (7 downto 0);
    signal aboveLeftX_mergedSignalTM_uid169_pT1_uid121_invPolyEval_q : STD_LOGIC_VECTOR (4 downto 0);
    signal aboveLeftY_bottomExtension_uid171_pT1_uid121_invPolyEval_q : STD_LOGIC_VECTOR (2 downto 0);
    signal aboveLeftY_mergedSignalTM_uid173_pT1_uid121_invPolyEval_q : STD_LOGIC_VECTOR (4 downto 0);
    signal n1_uid178_pT1_uid121_invPolyEval_b : STD_LOGIC_VECTOR (3 downto 0);
    signal n0_uid179_pT1_uid121_invPolyEval_b : STD_LOGIC_VECTOR (3 downto 0);
    signal sm0_uid186_pT1_uid121_invPolyEval_a0 : STD_LOGIC_VECTOR (7 downto 0);
    signal sm0_uid186_pT1_uid121_invPolyEval_b0 : STD_LOGIC_VECTOR (7 downto 0);
    signal sm0_uid186_pT1_uid121_invPolyEval_s1 : STD_LOGIC_VECTOR (15 downto 0);
    signal sm0_uid186_pT1_uid121_invPolyEval_reset : std_logic;
    signal sm0_uid186_pT1_uid121_invPolyEval_q : STD_LOGIC_VECTOR (15 downto 0);
    signal sm0_uid187_pT1_uid121_invPolyEval_a0 : STD_LOGIC_VECTOR (3 downto 0);
    signal sm0_uid187_pT1_uid121_invPolyEval_b0 : STD_LOGIC_VECTOR (4 downto 0);
    signal sm0_uid187_pT1_uid121_invPolyEval_s1 : STD_LOGIC_VECTOR (8 downto 0);
    signal sm0_uid187_pT1_uid121_invPolyEval_reset : std_logic;
    signal sm0_uid187_pT1_uid121_invPolyEval_q : STD_LOGIC_VECTOR (7 downto 0);
    signal lev1_a0_uid188_pT1_uid121_invPolyEval_a : STD_LOGIC_VECTOR (16 downto 0);
    signal lev1_a0_uid188_pT1_uid121_invPolyEval_b : STD_LOGIC_VECTOR (16 downto 0);
    signal lev1_a0_uid188_pT1_uid121_invPolyEval_o : STD_LOGIC_VECTOR (16 downto 0);
    signal lev1_a0_uid188_pT1_uid121_invPolyEval_q : STD_LOGIC_VECTOR (16 downto 0);
    signal osig_uid189_pT1_uid121_invPolyEval_in : STD_LOGIC_VECTOR (14 downto 0);
    signal osig_uid189_pT1_uid121_invPolyEval_b : STD_LOGIC_VECTOR (12 downto 0);
    signal memoryC0_uid112_invTables_lutmem_reset0 : std_logic;
    signal memoryC0_uid112_invTables_lutmem_ia : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC0_uid112_invTables_lutmem_aa : STD_LOGIC_VECTOR (6 downto 0);
    signal memoryC0_uid112_invTables_lutmem_ab : STD_LOGIC_VECTOR (6 downto 0);
    signal memoryC0_uid112_invTables_lutmem_ir : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC0_uid112_invTables_lutmem_r : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC1_uid115_invTables_lutmem_reset0 : std_logic;
    signal memoryC1_uid115_invTables_lutmem_ia : STD_LOGIC_VECTOR (9 downto 0);
    signal memoryC1_uid115_invTables_lutmem_aa : STD_LOGIC_VECTOR (6 downto 0);
    signal memoryC1_uid115_invTables_lutmem_ab : STD_LOGIC_VECTOR (6 downto 0);
    signal memoryC1_uid115_invTables_lutmem_ir : STD_LOGIC_VECTOR (9 downto 0);
    signal memoryC1_uid115_invTables_lutmem_r : STD_LOGIC_VECTOR (9 downto 0);
    signal invY_uid54_fpDivTest_merged_bit_select_in : STD_LOGIC_VECTOR (18 downto 0);
    signal invY_uid54_fpDivTest_merged_bit_select_b : STD_LOGIC_VECTOR (12 downto 0);
    signal invY_uid54_fpDivTest_merged_bit_select_c : STD_LOGIC_VECTOR (0 downto 0);
    signal topRangeY_uid166_pT1_uid121_invPolyEval_merged_bit_select_b : STD_LOGIC_VECTOR (7 downto 0);
    signal topRangeY_uid166_pT1_uid121_invPolyEval_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal redist0_lOAdded_uid58_fpDivTest_q_2_q : STD_LOGIC_VECTOR (10 downto 0);
    signal redist1_fracYPostZ_uid56_fpDivTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist2_yPE_uid52_fpDivTest_b_2_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist3_yAddr_uid51_fpDivTest_b_2_q : STD_LOGIC_VECTOR (6 downto 0);
    signal redist4_expXmY_uid47_fpDivTest_q_6_q : STD_LOGIC_VECTOR (5 downto 0);
    signal redist5_signR_uid46_fpDivTest_q_6_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist6_fracXIsZero_uid39_fpDivTest_q_6_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist7_expXIsMax_uid38_fpDivTest_q_6_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist8_excZ_y_uid37_fpDivTest_q_6_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist9_fracXIsZero_uid25_fpDivTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist10_expXIsMax_uid24_fpDivTest_q_6_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist11_excZ_x_uid23_fpDivTest_q_6_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist12_fracYZero_uid15_fpDivTest_q_4_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist13_fracX_uid10_fpDivTest_b_4_q : STD_LOGIC_VECTOR (9 downto 0);

begin


    -- fracY_uid13_fpDivTest(BITSELECT,12)@0
    fracY_uid13_fpDivTest_b <= b(9 downto 0);

    -- paddingY_uid15_fpDivTest(CONSTANT,14)
    paddingY_uid15_fpDivTest_q <= "0000000000";

    -- fracXIsZero_uid39_fpDivTest(LOGICAL,38)@0 + 1
    fracXIsZero_uid39_fpDivTest_qi <= "1" WHEN paddingY_uid15_fpDivTest_q = fracY_uid13_fpDivTest_b ELSE "0";
    fracXIsZero_uid39_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid39_fpDivTest_qi, xout => fracXIsZero_uid39_fpDivTest_q, ena => en(0), clk => clk, aclr => areset );

    -- redist6_fracXIsZero_uid39_fpDivTest_q_6(DELAY,200)
    redist6_fracXIsZero_uid39_fpDivTest_q_6 : dspba_delay
    GENERIC MAP ( width => 1, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid39_fpDivTest_q, xout => redist6_fracXIsZero_uid39_fpDivTest_q_6_q, ena => en(0), clk => clk, aclr => areset );

    -- cstAllOWE_uid18_fpDivTest(CONSTANT,17)
    cstAllOWE_uid18_fpDivTest_q <= "11111";

    -- expY_uid12_fpDivTest(BITSELECT,11)@0
    expY_uid12_fpDivTest_b <= b(14 downto 10);

    -- expXIsMax_uid38_fpDivTest(LOGICAL,37)@0 + 1
    expXIsMax_uid38_fpDivTest_qi <= "1" WHEN expY_uid12_fpDivTest_b = cstAllOWE_uid18_fpDivTest_q ELSE "0";
    expXIsMax_uid38_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid38_fpDivTest_qi, xout => expXIsMax_uid38_fpDivTest_q, ena => en(0), clk => clk, aclr => areset );

    -- redist7_expXIsMax_uid38_fpDivTest_q_6(DELAY,201)
    redist7_expXIsMax_uid38_fpDivTest_q_6 : dspba_delay
    GENERIC MAP ( width => 1, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid38_fpDivTest_q, xout => redist7_expXIsMax_uid38_fpDivTest_q_6_q, ena => en(0), clk => clk, aclr => areset );

    -- excI_y_uid41_fpDivTest(LOGICAL,40)@6
    excI_y_uid41_fpDivTest_q <= redist7_expXIsMax_uid38_fpDivTest_q_6_q and redist6_fracXIsZero_uid39_fpDivTest_q_6_q;

    -- fracX_uid10_fpDivTest(BITSELECT,9)@0
    fracX_uid10_fpDivTest_b <= a(9 downto 0);

    -- redist13_fracX_uid10_fpDivTest_b_4(DELAY,207)
    redist13_fracX_uid10_fpDivTest_b_4 : dspba_delay
    GENERIC MAP ( width => 10, depth => 4, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracX_uid10_fpDivTest_b, xout => redist13_fracX_uid10_fpDivTest_b_4_q, ena => en(0), clk => clk, aclr => areset );

    -- fracXIsZero_uid25_fpDivTest(LOGICAL,24)@4 + 1
    fracXIsZero_uid25_fpDivTest_qi <= "1" WHEN paddingY_uid15_fpDivTest_q = redist13_fracX_uid10_fpDivTest_b_4_q ELSE "0";
    fracXIsZero_uid25_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid25_fpDivTest_qi, xout => fracXIsZero_uid25_fpDivTest_q, ena => en(0), clk => clk, aclr => areset );

    -- redist9_fracXIsZero_uid25_fpDivTest_q_2(DELAY,203)
    redist9_fracXIsZero_uid25_fpDivTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid25_fpDivTest_q, xout => redist9_fracXIsZero_uid25_fpDivTest_q_2_q, ena => en(0), clk => clk, aclr => areset );

    -- expX_uid9_fpDivTest(BITSELECT,8)@0
    expX_uid9_fpDivTest_b <= a(14 downto 10);

    -- expXIsMax_uid24_fpDivTest(LOGICAL,23)@0 + 1
    expXIsMax_uid24_fpDivTest_qi <= "1" WHEN expX_uid9_fpDivTest_b = cstAllOWE_uid18_fpDivTest_q ELSE "0";
    expXIsMax_uid24_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid24_fpDivTest_qi, xout => expXIsMax_uid24_fpDivTest_q, ena => en(0), clk => clk, aclr => areset );

    -- redist10_expXIsMax_uid24_fpDivTest_q_6(DELAY,204)
    redist10_expXIsMax_uid24_fpDivTest_q_6 : dspba_delay
    GENERIC MAP ( width => 1, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid24_fpDivTest_q, xout => redist10_expXIsMax_uid24_fpDivTest_q_6_q, ena => en(0), clk => clk, aclr => areset );

    -- excI_x_uid27_fpDivTest(LOGICAL,26)@6
    excI_x_uid27_fpDivTest_q <= redist10_expXIsMax_uid24_fpDivTest_q_6_q and redist9_fracXIsZero_uid25_fpDivTest_q_2_q;

    -- excXIYI_uid96_fpDivTest(LOGICAL,95)@6
    excXIYI_uid96_fpDivTest_q <= excI_x_uid27_fpDivTest_q and excI_y_uid41_fpDivTest_q;

    -- fracXIsNotZero_uid40_fpDivTest(LOGICAL,39)@6
    fracXIsNotZero_uid40_fpDivTest_q <= not (redist6_fracXIsZero_uid39_fpDivTest_q_6_q);

    -- excN_y_uid42_fpDivTest(LOGICAL,41)@6
    excN_y_uid42_fpDivTest_q <= redist7_expXIsMax_uid38_fpDivTest_q_6_q and fracXIsNotZero_uid40_fpDivTest_q;

    -- fracXIsNotZero_uid26_fpDivTest(LOGICAL,25)@6
    fracXIsNotZero_uid26_fpDivTest_q <= not (redist9_fracXIsZero_uid25_fpDivTest_q_2_q);

    -- excN_x_uid28_fpDivTest(LOGICAL,27)@6
    excN_x_uid28_fpDivTest_q <= redist10_expXIsMax_uid24_fpDivTest_q_6_q and fracXIsNotZero_uid26_fpDivTest_q;

    -- cstAllZWE_uid20_fpDivTest(CONSTANT,19)
    cstAllZWE_uid20_fpDivTest_q <= "00000";

    -- excZ_y_uid37_fpDivTest(LOGICAL,36)@0 + 1
    excZ_y_uid37_fpDivTest_qi <= "1" WHEN expY_uid12_fpDivTest_b = cstAllZWE_uid20_fpDivTest_q ELSE "0";
    excZ_y_uid37_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_y_uid37_fpDivTest_qi, xout => excZ_y_uid37_fpDivTest_q, ena => en(0), clk => clk, aclr => areset );

    -- redist8_excZ_y_uid37_fpDivTest_q_6(DELAY,202)
    redist8_excZ_y_uid37_fpDivTest_q_6 : dspba_delay
    GENERIC MAP ( width => 1, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_y_uid37_fpDivTest_q, xout => redist8_excZ_y_uid37_fpDivTest_q_6_q, ena => en(0), clk => clk, aclr => areset );

    -- excZ_x_uid23_fpDivTest(LOGICAL,22)@0 + 1
    excZ_x_uid23_fpDivTest_qi <= "1" WHEN expX_uid9_fpDivTest_b = cstAllZWE_uid20_fpDivTest_q ELSE "0";
    excZ_x_uid23_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_x_uid23_fpDivTest_qi, xout => excZ_x_uid23_fpDivTest_q, ena => en(0), clk => clk, aclr => areset );

    -- redist11_excZ_x_uid23_fpDivTest_q_6(DELAY,205)
    redist11_excZ_x_uid23_fpDivTest_q_6 : dspba_delay
    GENERIC MAP ( width => 1, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_x_uid23_fpDivTest_q, xout => redist11_excZ_x_uid23_fpDivTest_q_6_q, ena => en(0), clk => clk, aclr => areset );

    -- excXZYZ_uid95_fpDivTest(LOGICAL,94)@6
    excXZYZ_uid95_fpDivTest_q <= redist11_excZ_x_uid23_fpDivTest_q_6_q and redist8_excZ_y_uid37_fpDivTest_q_6_q;

    -- excRNaN_uid97_fpDivTest(LOGICAL,96)@6
    excRNaN_uid97_fpDivTest_q <= excXZYZ_uid95_fpDivTest_q or excN_x_uid28_fpDivTest_q or excN_y_uid42_fpDivTest_q or excXIYI_uid96_fpDivTest_q;

    -- invExcRNaN_uid108_fpDivTest(LOGICAL,107)@6
    invExcRNaN_uid108_fpDivTest_q <= not (excRNaN_uid97_fpDivTest_q);

    -- signY_uid14_fpDivTest(BITSELECT,13)@0
    signY_uid14_fpDivTest_b <= STD_LOGIC_VECTOR(b(15 downto 15));

    -- signX_uid11_fpDivTest(BITSELECT,10)@0
    signX_uid11_fpDivTest_b <= STD_LOGIC_VECTOR(a(15 downto 15));

    -- signR_uid46_fpDivTest(LOGICAL,45)@0 + 1
    signR_uid46_fpDivTest_qi <= signX_uid11_fpDivTest_b xor signY_uid14_fpDivTest_b;
    signR_uid46_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => signR_uid46_fpDivTest_qi, xout => signR_uid46_fpDivTest_q, ena => en(0), clk => clk, aclr => areset );

    -- redist5_signR_uid46_fpDivTest_q_6(DELAY,199)
    redist5_signR_uid46_fpDivTest_q_6 : dspba_delay
    GENERIC MAP ( width => 1, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => signR_uid46_fpDivTest_q, xout => redist5_signR_uid46_fpDivTest_q_6_q, ena => en(0), clk => clk, aclr => areset );

    -- sRPostExc_uid109_fpDivTest(LOGICAL,108)@6
    sRPostExc_uid109_fpDivTest_q <= redist5_signR_uid46_fpDivTest_q_6_q and invExcRNaN_uid108_fpDivTest_q;

    -- lOAdded_uid58_fpDivTest(BITJOIN,57)@4
    lOAdded_uid58_fpDivTest_q <= VCC_q & redist13_fracX_uid10_fpDivTest_b_4_q;

    -- redist0_lOAdded_uid58_fpDivTest_q_2(DELAY,194)
    redist0_lOAdded_uid58_fpDivTest_q_2 : dspba_delay
    GENERIC MAP ( width => 11, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => lOAdded_uid58_fpDivTest_q, xout => redist0_lOAdded_uid58_fpDivTest_q_2_q, ena => en(0), clk => clk, aclr => areset );

    -- oFracXSE_bottomExtension_uid61_fpDivTest(CONSTANT,60)
    oFracXSE_bottomExtension_uid61_fpDivTest_q <= "00";

    -- oFracXSE_mergedSignalTM_uid63_fpDivTest(BITJOIN,62)@6
    oFracXSE_mergedSignalTM_uid63_fpDivTest_q <= redist0_lOAdded_uid58_fpDivTest_q_2_q & oFracXSE_bottomExtension_uid61_fpDivTest_q;

    -- topRangeY_bottomExtension_uid146_prodDivPreNormProd_uid60_fpDivTest(CONSTANT,145)
    topRangeY_bottomExtension_uid146_prodDivPreNormProd_uid60_fpDivTest_q <= "0000000";

    -- topRangeY_mergedSignalTM_uid148_prodDivPreNormProd_uid60_fpDivTest(BITJOIN,147)@4
    topRangeY_mergedSignalTM_uid148_prodDivPreNormProd_uid60_fpDivTest_q <= lOAdded_uid58_fpDivTest_q & topRangeY_bottomExtension_uid146_prodDivPreNormProd_uid60_fpDivTest_q;

    -- yAddr_uid51_fpDivTest(BITSELECT,50)@0
    yAddr_uid51_fpDivTest_b <= fracY_uid13_fpDivTest_b(9 downto 3);

    -- memoryC1_uid115_invTables_lutmem(DUALMEM,191)@0 + 2
    -- in j@20000000
    memoryC1_uid115_invTables_lutmem_aa <= yAddr_uid51_fpDivTest_b;
    memoryC1_uid115_invTables_lutmem_reset0 <= areset;
    memoryC1_uid115_invTables_lutmem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "ROM",
        width_a => 10,
        widthad_a => 7,
        numwords_a => 128,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "FPDiv_0002_memoryC1_uid115_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "Cyclone IV E"
    )
    PORT MAP (
        clocken0 => en(0),
        aclr0 => memoryC1_uid115_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC1_uid115_invTables_lutmem_aa,
        q_a => memoryC1_uid115_invTables_lutmem_ir
    );
    memoryC1_uid115_invTables_lutmem_r <= memoryC1_uid115_invTables_lutmem_ir(9 downto 0);

    -- topRangeY_uid166_pT1_uid121_invPolyEval_merged_bit_select(BITSELECT,193)@2
    topRangeY_uid166_pT1_uid121_invPolyEval_merged_bit_select_b <= STD_LOGIC_VECTOR(memoryC1_uid115_invTables_lutmem_r(9 downto 2));
    topRangeY_uid166_pT1_uid121_invPolyEval_merged_bit_select_c <= STD_LOGIC_VECTOR(memoryC1_uid115_invTables_lutmem_r(1 downto 0));

    -- aboveLeftY_bottomExtension_uid171_pT1_uid121_invPolyEval(CONSTANT,170)
    aboveLeftY_bottomExtension_uid171_pT1_uid121_invPolyEval_q <= "000";

    -- aboveLeftY_mergedSignalTM_uid173_pT1_uid121_invPolyEval(BITJOIN,172)@2
    aboveLeftY_mergedSignalTM_uid173_pT1_uid121_invPolyEval_q <= topRangeY_uid166_pT1_uid121_invPolyEval_merged_bit_select_c & aboveLeftY_bottomExtension_uid171_pT1_uid121_invPolyEval_q;

    -- n1_uid178_pT1_uid121_invPolyEval(BITSELECT,177)@2
    n1_uid178_pT1_uid121_invPolyEval_b <= aboveLeftY_mergedSignalTM_uid173_pT1_uid121_invPolyEval_q(4 downto 1);

    -- yPE_uid52_fpDivTest(BITSELECT,51)@0
    yPE_uid52_fpDivTest_b <= b(2 downto 0);

    -- redist2_yPE_uid52_fpDivTest_b_2(DELAY,196)
    redist2_yPE_uid52_fpDivTest_b_2 : dspba_delay
    GENERIC MAP ( width => 3, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => yPE_uid52_fpDivTest_b, xout => redist2_yPE_uid52_fpDivTest_b_2_q, ena => en(0), clk => clk, aclr => areset );

    -- nx_mergedSignalTM_uid155_pT1_uid121_invPolyEval(BITJOIN,154)@2
    nx_mergedSignalTM_uid155_pT1_uid121_invPolyEval_q <= GND_q & redist2_yPE_uid52_fpDivTest_b_2_q;

    -- GND(CONSTANT,0)
    GND_q <= "0";

    -- aboveLeftX_mergedSignalTM_uid169_pT1_uid121_invPolyEval(BITJOIN,168)@2
    aboveLeftX_mergedSignalTM_uid169_pT1_uid121_invPolyEval_q <= nx_mergedSignalTM_uid155_pT1_uid121_invPolyEval_q & GND_q;

    -- n0_uid179_pT1_uid121_invPolyEval(BITSELECT,178)@2
    n0_uid179_pT1_uid121_invPolyEval_b <= STD_LOGIC_VECTOR(aboveLeftX_mergedSignalTM_uid169_pT1_uid121_invPolyEval_q(4 downto 1));

    -- sm0_uid187_pT1_uid121_invPolyEval(MULT,186)@2 + 2
    sm0_uid187_pT1_uid121_invPolyEval_a0 <= STD_LOGIC_VECTOR(n0_uid179_pT1_uid121_invPolyEval_b);
    sm0_uid187_pT1_uid121_invPolyEval_b0 <= '0' & n1_uid178_pT1_uid121_invPolyEval_b;
    sm0_uid187_pT1_uid121_invPolyEval_reset <= areset;
    sm0_uid187_pT1_uid121_invPolyEval_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 4,
        lpm_widthb => 5,
        lpm_widthp => 9,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=NO, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid187_pT1_uid121_invPolyEval_a0,
        datab => sm0_uid187_pT1_uid121_invPolyEval_b0,
        clken => en(0),
        aclr => sm0_uid187_pT1_uid121_invPolyEval_reset,
        clock => clk,
        result => sm0_uid187_pT1_uid121_invPolyEval_s1
    );
    sm0_uid187_pT1_uid121_invPolyEval_q <= sm0_uid187_pT1_uid121_invPolyEval_s1(7 downto 0);

    -- topRangeX_bottomExtension_uid162_pT1_uid121_invPolyEval(CONSTANT,161)
    topRangeX_bottomExtension_uid162_pT1_uid121_invPolyEval_q <= "0000";

    -- topRangeX_mergedSignalTM_uid164_pT1_uid121_invPolyEval(BITJOIN,163)@2
    topRangeX_mergedSignalTM_uid164_pT1_uid121_invPolyEval_q <= nx_mergedSignalTM_uid155_pT1_uid121_invPolyEval_q & topRangeX_bottomExtension_uid162_pT1_uid121_invPolyEval_q;

    -- sm0_uid186_pT1_uid121_invPolyEval(MULT,185)@2 + 2
    sm0_uid186_pT1_uid121_invPolyEval_a0 <= STD_LOGIC_VECTOR(topRangeX_mergedSignalTM_uid164_pT1_uid121_invPolyEval_q);
    sm0_uid186_pT1_uid121_invPolyEval_b0 <= STD_LOGIC_VECTOR(topRangeY_uid166_pT1_uid121_invPolyEval_merged_bit_select_b);
    sm0_uid186_pT1_uid121_invPolyEval_reset <= areset;
    sm0_uid186_pT1_uid121_invPolyEval_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 8,
        lpm_widthb => 8,
        lpm_widthp => 16,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid186_pT1_uid121_invPolyEval_a0,
        datab => sm0_uid186_pT1_uid121_invPolyEval_b0,
        clken => en(0),
        aclr => sm0_uid186_pT1_uid121_invPolyEval_reset,
        clock => clk,
        result => sm0_uid186_pT1_uid121_invPolyEval_s1
    );
    sm0_uid186_pT1_uid121_invPolyEval_q <= sm0_uid186_pT1_uid121_invPolyEval_s1;

    -- lev1_a0_uid188_pT1_uid121_invPolyEval(ADD,187)@4
    lev1_a0_uid188_pT1_uid121_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => sm0_uid186_pT1_uid121_invPolyEval_q(15)) & sm0_uid186_pT1_uid121_invPolyEval_q));
    lev1_a0_uid188_pT1_uid121_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 8 => sm0_uid187_pT1_uid121_invPolyEval_q(7)) & sm0_uid187_pT1_uid121_invPolyEval_q));
    lev1_a0_uid188_pT1_uid121_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(lev1_a0_uid188_pT1_uid121_invPolyEval_a) + SIGNED(lev1_a0_uid188_pT1_uid121_invPolyEval_b));
    lev1_a0_uid188_pT1_uid121_invPolyEval_q <= lev1_a0_uid188_pT1_uid121_invPolyEval_o(16 downto 0);

    -- osig_uid189_pT1_uid121_invPolyEval(BITSELECT,188)@4
    osig_uid189_pT1_uid121_invPolyEval_in <= STD_LOGIC_VECTOR(lev1_a0_uid188_pT1_uid121_invPolyEval_q(14 downto 0));
    osig_uid189_pT1_uid121_invPolyEval_b <= STD_LOGIC_VECTOR(osig_uid189_pT1_uid121_invPolyEval_in(14 downto 2));

    -- redist3_yAddr_uid51_fpDivTest_b_2(DELAY,197)
    redist3_yAddr_uid51_fpDivTest_b_2 : dspba_delay
    GENERIC MAP ( width => 7, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => yAddr_uid51_fpDivTest_b, xout => redist3_yAddr_uid51_fpDivTest_b_2_q, ena => en(0), clk => clk, aclr => areset );

    -- memoryC0_uid112_invTables_lutmem(DUALMEM,190)@2 + 2
    -- in j@20000000
    memoryC0_uid112_invTables_lutmem_aa <= redist3_yAddr_uid51_fpDivTest_b_2_q;
    memoryC0_uid112_invTables_lutmem_reset0 <= areset;
    memoryC0_uid112_invTables_lutmem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "ROM",
        width_a => 18,
        widthad_a => 7,
        numwords_a => 128,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "FPDiv_0002_memoryC0_uid112_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "Cyclone IV E"
    )
    PORT MAP (
        clocken0 => en(0),
        aclr0 => memoryC0_uid112_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC0_uid112_invTables_lutmem_aa,
        q_a => memoryC0_uid112_invTables_lutmem_ir
    );
    memoryC0_uid112_invTables_lutmem_r <= memoryC0_uid112_invTables_lutmem_ir(17 downto 0);

    -- rndBit_uid122_invPolyEval(CONSTANT,121)
    rndBit_uid122_invPolyEval_q <= "001";

    -- cIncludingRoundingBit_uid123_invPolyEval(BITJOIN,122)@4
    cIncludingRoundingBit_uid123_invPolyEval_q <= memoryC0_uid112_invTables_lutmem_r & rndBit_uid122_invPolyEval_q;

    -- ts1_uid125_invPolyEval(ADD,124)@4
    ts1_uid125_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((21 downto 21 => cIncludingRoundingBit_uid123_invPolyEval_q(20)) & cIncludingRoundingBit_uid123_invPolyEval_q));
    ts1_uid125_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((21 downto 13 => osig_uid189_pT1_uid121_invPolyEval_b(12)) & osig_uid189_pT1_uid121_invPolyEval_b));
    ts1_uid125_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(ts1_uid125_invPolyEval_a) + SIGNED(ts1_uid125_invPolyEval_b));
    ts1_uid125_invPolyEval_q <= ts1_uid125_invPolyEval_o(21 downto 0);

    -- s1_uid126_invPolyEval(BITSELECT,125)@4
    s1_uid126_invPolyEval_b <= STD_LOGIC_VECTOR(ts1_uid125_invPolyEval_q(21 downto 1));

    -- invY_uid54_fpDivTest_merged_bit_select(BITSELECT,192)@4
    invY_uid54_fpDivTest_merged_bit_select_in <= s1_uid126_invPolyEval_b(18 downto 0);
    invY_uid54_fpDivTest_merged_bit_select_b <= invY_uid54_fpDivTest_merged_bit_select_in(17 downto 5);
    invY_uid54_fpDivTest_merged_bit_select_c <= invY_uid54_fpDivTest_merged_bit_select_in(18 downto 18);

    -- topRangeX_mergedSignalTM_uid144_prodDivPreNormProd_uid60_fpDivTest(BITJOIN,143)@4
    topRangeX_mergedSignalTM_uid144_prodDivPreNormProd_uid60_fpDivTest_q <= invY_uid54_fpDivTest_merged_bit_select_b & cstAllZWE_uid20_fpDivTest_q;

    -- sm0_uid150_prodDivPreNormProd_uid60_fpDivTest(MULT,149)@4 + 2
    sm0_uid150_prodDivPreNormProd_uid60_fpDivTest_a0 <= topRangeX_mergedSignalTM_uid144_prodDivPreNormProd_uid60_fpDivTest_q;
    sm0_uid150_prodDivPreNormProd_uid60_fpDivTest_b0 <= topRangeY_mergedSignalTM_uid148_prodDivPreNormProd_uid60_fpDivTest_q;
    sm0_uid150_prodDivPreNormProd_uid60_fpDivTest_reset <= areset;
    sm0_uid150_prodDivPreNormProd_uid60_fpDivTest_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 18,
        lpm_widthb => 18,
        lpm_widthp => 36,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "UNSIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid150_prodDivPreNormProd_uid60_fpDivTest_a0,
        datab => sm0_uid150_prodDivPreNormProd_uid60_fpDivTest_b0,
        clken => en(0),
        aclr => sm0_uid150_prodDivPreNormProd_uid60_fpDivTest_reset,
        clock => clk,
        result => sm0_uid150_prodDivPreNormProd_uid60_fpDivTest_s1
    );
    sm0_uid150_prodDivPreNormProd_uid60_fpDivTest_q <= sm0_uid150_prodDivPreNormProd_uid60_fpDivTest_s1;

    -- osig_uid151_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,150)@6
    osig_uid151_prodDivPreNormProd_uid60_fpDivTest_b <= sm0_uid150_prodDivPreNormProd_uid60_fpDivTest_q(35 downto 22);

    -- divValPreNormS_uid65_fpDivTest(BITSELECT,64)@6
    divValPreNormS_uid65_fpDivTest_b <= osig_uid151_prodDivPreNormProd_uid60_fpDivTest_b(13 downto 1);

    -- updatedY_uid16_fpDivTest(BITJOIN,15)@0
    updatedY_uid16_fpDivTest_q <= GND_q & paddingY_uid15_fpDivTest_q;

    -- fracYZero_uid15_fpDivTest(LOGICAL,16)@0 + 1
    fracYZero_uid15_fpDivTest_a <= STD_LOGIC_VECTOR("0" & fracY_uid13_fpDivTest_b);
    fracYZero_uid15_fpDivTest_qi <= "1" WHEN fracYZero_uid15_fpDivTest_a = updatedY_uid16_fpDivTest_q ELSE "0";
    fracYZero_uid15_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracYZero_uid15_fpDivTest_qi, xout => fracYZero_uid15_fpDivTest_q, ena => en(0), clk => clk, aclr => areset );

    -- redist12_fracYZero_uid15_fpDivTest_q_4(DELAY,206)
    redist12_fracYZero_uid15_fpDivTest_q_4 : dspba_delay
    GENERIC MAP ( width => 1, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracYZero_uid15_fpDivTest_q, xout => redist12_fracYZero_uid15_fpDivTest_q_4_q, ena => en(0), clk => clk, aclr => areset );

    -- fracYPostZ_uid56_fpDivTest(LOGICAL,55)@4 + 1
    fracYPostZ_uid56_fpDivTest_qi <= redist12_fracYZero_uid15_fpDivTest_q_4_q or invY_uid54_fpDivTest_merged_bit_select_c;
    fracYPostZ_uid56_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracYPostZ_uid56_fpDivTest_qi, xout => fracYPostZ_uid56_fpDivTest_q, ena => en(0), clk => clk, aclr => areset );

    -- redist1_fracYPostZ_uid56_fpDivTest_q_2(DELAY,195)
    redist1_fracYPostZ_uid56_fpDivTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracYPostZ_uid56_fpDivTest_q, xout => redist1_fracYPostZ_uid56_fpDivTest_q_2_q, ena => en(0), clk => clk, aclr => areset );

    -- divValPreNormTrunc_uid66_fpDivTest(MUX,65)@6
    divValPreNormTrunc_uid66_fpDivTest_s <= redist1_fracYPostZ_uid56_fpDivTest_q_2_q;
    divValPreNormTrunc_uid66_fpDivTest_combproc: PROCESS (divValPreNormTrunc_uid66_fpDivTest_s, en, divValPreNormS_uid65_fpDivTest_b, oFracXSE_mergedSignalTM_uid63_fpDivTest_q)
    BEGIN
        CASE (divValPreNormTrunc_uid66_fpDivTest_s) IS
            WHEN "0" => divValPreNormTrunc_uid66_fpDivTest_q <= divValPreNormS_uid65_fpDivTest_b;
            WHEN "1" => divValPreNormTrunc_uid66_fpDivTest_q <= oFracXSE_mergedSignalTM_uid63_fpDivTest_q;
            WHEN OTHERS => divValPreNormTrunc_uid66_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- norm_uid67_fpDivTest(BITSELECT,66)@6
    norm_uid67_fpDivTest_b <= STD_LOGIC_VECTOR(divValPreNormTrunc_uid66_fpDivTest_q(12 downto 12));

    -- VCC(CONSTANT,1)
    VCC_q <= "1";

    -- rndOp_uid75_fpDivTest(BITJOIN,74)@6
    rndOp_uid75_fpDivTest_q <= norm_uid67_fpDivTest_b & paddingY_uid15_fpDivTest_q & VCC_q;

    -- cstBiasM1_uid6_fpDivTest(CONSTANT,5)
    cstBiasM1_uid6_fpDivTest_q <= "01110";

    -- expXmY_uid47_fpDivTest(SUB,46)@0 + 1
    expXmY_uid47_fpDivTest_a <= STD_LOGIC_VECTOR("0" & expX_uid9_fpDivTest_b);
    expXmY_uid47_fpDivTest_b <= STD_LOGIC_VECTOR("0" & expY_uid12_fpDivTest_b);
    expXmY_uid47_fpDivTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expXmY_uid47_fpDivTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (en = "1") THEN
                expXmY_uid47_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expXmY_uid47_fpDivTest_a) - UNSIGNED(expXmY_uid47_fpDivTest_b));
            END IF;
        END IF;
    END PROCESS;
    expXmY_uid47_fpDivTest_q <= expXmY_uid47_fpDivTest_o(5 downto 0);

    -- redist4_expXmY_uid47_fpDivTest_q_6(DELAY,198)
    redist4_expXmY_uid47_fpDivTest_q_6 : dspba_delay
    GENERIC MAP ( width => 6, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXmY_uid47_fpDivTest_q, xout => redist4_expXmY_uid47_fpDivTest_q_6_q, ena => en(0), clk => clk, aclr => areset );

    -- expR_uid48_fpDivTest(ADD,47)@6
    expR_uid48_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((7 downto 6 => redist4_expXmY_uid47_fpDivTest_q_6_q(5)) & redist4_expXmY_uid47_fpDivTest_q_6_q));
    expR_uid48_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("000" & cstBiasM1_uid6_fpDivTest_q));
    expR_uid48_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(expR_uid48_fpDivTest_a) + SIGNED(expR_uid48_fpDivTest_b));
    expR_uid48_fpDivTest_q <= expR_uid48_fpDivTest_o(6 downto 0);

    -- divValPreNormHigh_uid68_fpDivTest(BITSELECT,67)@6
    divValPreNormHigh_uid68_fpDivTest_in <= divValPreNormTrunc_uid66_fpDivTest_q(11 downto 0);
    divValPreNormHigh_uid68_fpDivTest_b <= divValPreNormHigh_uid68_fpDivTest_in(11 downto 1);

    -- divValPreNormLow_uid69_fpDivTest(BITSELECT,68)@6
    divValPreNormLow_uid69_fpDivTest_in <= divValPreNormTrunc_uid66_fpDivTest_q(10 downto 0);
    divValPreNormLow_uid69_fpDivTest_b <= divValPreNormLow_uid69_fpDivTest_in(10 downto 0);

    -- normFracRnd_uid70_fpDivTest(MUX,69)@6
    normFracRnd_uid70_fpDivTest_s <= norm_uid67_fpDivTest_b;
    normFracRnd_uid70_fpDivTest_combproc: PROCESS (normFracRnd_uid70_fpDivTest_s, en, divValPreNormLow_uid69_fpDivTest_b, divValPreNormHigh_uid68_fpDivTest_b)
    BEGIN
        CASE (normFracRnd_uid70_fpDivTest_s) IS
            WHEN "0" => normFracRnd_uid70_fpDivTest_q <= divValPreNormLow_uid69_fpDivTest_b;
            WHEN "1" => normFracRnd_uid70_fpDivTest_q <= divValPreNormHigh_uid68_fpDivTest_b;
            WHEN OTHERS => normFracRnd_uid70_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- expFracRnd_uid71_fpDivTest(BITJOIN,70)@6
    expFracRnd_uid71_fpDivTest_q <= expR_uid48_fpDivTest_q & normFracRnd_uid70_fpDivTest_q;

    -- expFracPostRnd_uid76_fpDivTest(ADD,75)@6
    expFracPostRnd_uid76_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((19 downto 18 => expFracRnd_uid71_fpDivTest_q(17)) & expFracRnd_uid71_fpDivTest_q));
    expFracPostRnd_uid76_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("00000000" & rndOp_uid75_fpDivTest_q));
    expFracPostRnd_uid76_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(expFracPostRnd_uid76_fpDivTest_a) + SIGNED(expFracPostRnd_uid76_fpDivTest_b));
    expFracPostRnd_uid76_fpDivTest_q <= expFracPostRnd_uid76_fpDivTest_o(18 downto 0);

    -- excRPreExc_uid79_fpDivTest(BITSELECT,78)@6
    excRPreExc_uid79_fpDivTest_in <= expFracPostRnd_uid76_fpDivTest_q(15 downto 0);
    excRPreExc_uid79_fpDivTest_b <= excRPreExc_uid79_fpDivTest_in(15 downto 11);

    -- invExpXIsMax_uid43_fpDivTest(LOGICAL,42)@6
    invExpXIsMax_uid43_fpDivTest_q <= not (redist7_expXIsMax_uid38_fpDivTest_q_6_q);

    -- InvExpXIsZero_uid44_fpDivTest(LOGICAL,43)@6
    InvExpXIsZero_uid44_fpDivTest_q <= not (redist8_excZ_y_uid37_fpDivTest_q_6_q);

    -- excR_y_uid45_fpDivTest(LOGICAL,44)@6
    excR_y_uid45_fpDivTest_q <= InvExpXIsZero_uid44_fpDivTest_q and invExpXIsMax_uid43_fpDivTest_q;

    -- excXIYR_uid93_fpDivTest(LOGICAL,92)@6
    excXIYR_uid93_fpDivTest_q <= excI_x_uid27_fpDivTest_q and excR_y_uid45_fpDivTest_q;

    -- excXIYZ_uid92_fpDivTest(LOGICAL,91)@6
    excXIYZ_uid92_fpDivTest_q <= excI_x_uid27_fpDivTest_q and redist8_excZ_y_uid37_fpDivTest_q_6_q;

    -- expRExt_uid80_fpDivTest(BITSELECT,79)@6
    expRExt_uid80_fpDivTest_b <= STD_LOGIC_VECTOR(expFracPostRnd_uid76_fpDivTest_q(18 downto 11));

    -- expOvf_uid84_fpDivTest(COMPARE,83)@6
    expOvf_uid84_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((9 downto 8 => expRExt_uid80_fpDivTest_b(7)) & expRExt_uid80_fpDivTest_b));
    expOvf_uid84_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("00000" & cstAllOWE_uid18_fpDivTest_q));
    expOvf_uid84_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(expOvf_uid84_fpDivTest_a) - SIGNED(expOvf_uid84_fpDivTest_b));
    expOvf_uid84_fpDivTest_n(0) <= not (expOvf_uid84_fpDivTest_o(9));

    -- invExpXIsMax_uid29_fpDivTest(LOGICAL,28)@6
    invExpXIsMax_uid29_fpDivTest_q <= not (redist10_expXIsMax_uid24_fpDivTest_q_6_q);

    -- InvExpXIsZero_uid30_fpDivTest(LOGICAL,29)@6
    InvExpXIsZero_uid30_fpDivTest_q <= not (redist11_excZ_x_uid23_fpDivTest_q_6_q);

    -- excR_x_uid31_fpDivTest(LOGICAL,30)@6
    excR_x_uid31_fpDivTest_q <= InvExpXIsZero_uid30_fpDivTest_q and invExpXIsMax_uid29_fpDivTest_q;

    -- excXRYROvf_uid91_fpDivTest(LOGICAL,90)@6
    excXRYROvf_uid91_fpDivTest_q <= excR_x_uid31_fpDivTest_q and excR_y_uid45_fpDivTest_q and expOvf_uid84_fpDivTest_n;

    -- excXRYZ_uid90_fpDivTest(LOGICAL,89)@6
    excXRYZ_uid90_fpDivTest_q <= excR_x_uid31_fpDivTest_q and redist8_excZ_y_uid37_fpDivTest_q_6_q;

    -- excRInf_uid94_fpDivTest(LOGICAL,93)@6
    excRInf_uid94_fpDivTest_q <= excXRYZ_uid90_fpDivTest_q or excXRYROvf_uid91_fpDivTest_q or excXIYZ_uid92_fpDivTest_q or excXIYR_uid93_fpDivTest_q;

    -- xRegOrZero_uid87_fpDivTest(LOGICAL,86)@6
    xRegOrZero_uid87_fpDivTest_q <= excR_x_uid31_fpDivTest_q or redist11_excZ_x_uid23_fpDivTest_q_6_q;

    -- regOrZeroOverInf_uid88_fpDivTest(LOGICAL,87)@6
    regOrZeroOverInf_uid88_fpDivTest_q <= xRegOrZero_uid87_fpDivTest_q and excI_y_uid41_fpDivTest_q;

    -- expUdf_uid81_fpDivTest(COMPARE,80)@6
    expUdf_uid81_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("000000000" & GND_q));
    expUdf_uid81_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((9 downto 8 => expRExt_uid80_fpDivTest_b(7)) & expRExt_uid80_fpDivTest_b));
    expUdf_uid81_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(expUdf_uid81_fpDivTest_a) - SIGNED(expUdf_uid81_fpDivTest_b));
    expUdf_uid81_fpDivTest_n(0) <= not (expUdf_uid81_fpDivTest_o(9));

    -- regOverRegWithUf_uid86_fpDivTest(LOGICAL,85)@6
    regOverRegWithUf_uid86_fpDivTest_q <= expUdf_uid81_fpDivTest_n and excR_x_uid31_fpDivTest_q and excR_y_uid45_fpDivTest_q;

    -- zeroOverReg_uid85_fpDivTest(LOGICAL,84)@6
    zeroOverReg_uid85_fpDivTest_q <= redist11_excZ_x_uid23_fpDivTest_q_6_q and excR_y_uid45_fpDivTest_q;

    -- excRZero_uid89_fpDivTest(LOGICAL,88)@6
    excRZero_uid89_fpDivTest_q <= zeroOverReg_uid85_fpDivTest_q or regOverRegWithUf_uid86_fpDivTest_q or regOrZeroOverInf_uid88_fpDivTest_q;

    -- concExc_uid98_fpDivTest(BITJOIN,97)@6
    concExc_uid98_fpDivTest_q <= excRNaN_uid97_fpDivTest_q & excRInf_uid94_fpDivTest_q & excRZero_uid89_fpDivTest_q;

    -- excREnc_uid99_fpDivTest(LOOKUP,98)@6
    excREnc_uid99_fpDivTest_combproc: PROCESS (concExc_uid98_fpDivTest_q)
    BEGIN
        -- Begin reserved scope level
        CASE (concExc_uid98_fpDivTest_q) IS
            WHEN "000" => excREnc_uid99_fpDivTest_q <= "01";
            WHEN "001" => excREnc_uid99_fpDivTest_q <= "00";
            WHEN "010" => excREnc_uid99_fpDivTest_q <= "10";
            WHEN "011" => excREnc_uid99_fpDivTest_q <= "00";
            WHEN "100" => excREnc_uid99_fpDivTest_q <= "11";
            WHEN "101" => excREnc_uid99_fpDivTest_q <= "00";
            WHEN "110" => excREnc_uid99_fpDivTest_q <= "00";
            WHEN "111" => excREnc_uid99_fpDivTest_q <= "00";
            WHEN OTHERS => -- unreachable
                           excREnc_uid99_fpDivTest_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- expRPostExc_uid107_fpDivTest(MUX,106)@6
    expRPostExc_uid107_fpDivTest_s <= excREnc_uid99_fpDivTest_q;
    expRPostExc_uid107_fpDivTest_combproc: PROCESS (expRPostExc_uid107_fpDivTest_s, en, cstAllZWE_uid20_fpDivTest_q, excRPreExc_uid79_fpDivTest_b, cstAllOWE_uid18_fpDivTest_q)
    BEGIN
        CASE (expRPostExc_uid107_fpDivTest_s) IS
            WHEN "00" => expRPostExc_uid107_fpDivTest_q <= cstAllZWE_uid20_fpDivTest_q;
            WHEN "01" => expRPostExc_uid107_fpDivTest_q <= excRPreExc_uid79_fpDivTest_b;
            WHEN "10" => expRPostExc_uid107_fpDivTest_q <= cstAllOWE_uid18_fpDivTest_q;
            WHEN "11" => expRPostExc_uid107_fpDivTest_q <= cstAllOWE_uid18_fpDivTest_q;
            WHEN OTHERS => expRPostExc_uid107_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- oneFracRPostExc2_uid100_fpDivTest(CONSTANT,99)
    oneFracRPostExc2_uid100_fpDivTest_q <= "0000000001";

    -- fracRPreExc_uid78_fpDivTest(BITSELECT,77)@6
    fracRPreExc_uid78_fpDivTest_in <= expFracPostRnd_uid76_fpDivTest_q(10 downto 0);
    fracRPreExc_uid78_fpDivTest_b <= fracRPreExc_uid78_fpDivTest_in(10 downto 1);

    -- fracRPostExc_uid103_fpDivTest(MUX,102)@6
    fracRPostExc_uid103_fpDivTest_s <= excREnc_uid99_fpDivTest_q;
    fracRPostExc_uid103_fpDivTest_combproc: PROCESS (fracRPostExc_uid103_fpDivTest_s, en, paddingY_uid15_fpDivTest_q, fracRPreExc_uid78_fpDivTest_b, oneFracRPostExc2_uid100_fpDivTest_q)
    BEGIN
        CASE (fracRPostExc_uid103_fpDivTest_s) IS
            WHEN "00" => fracRPostExc_uid103_fpDivTest_q <= paddingY_uid15_fpDivTest_q;
            WHEN "01" => fracRPostExc_uid103_fpDivTest_q <= fracRPreExc_uid78_fpDivTest_b;
            WHEN "10" => fracRPostExc_uid103_fpDivTest_q <= paddingY_uid15_fpDivTest_q;
            WHEN "11" => fracRPostExc_uid103_fpDivTest_q <= oneFracRPostExc2_uid100_fpDivTest_q;
            WHEN OTHERS => fracRPostExc_uid103_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- divR_uid110_fpDivTest(BITJOIN,109)@6
    divR_uid110_fpDivTest_q <= sRPostExc_uid109_fpDivTest_q & expRPostExc_uid107_fpDivTest_q & fracRPostExc_uid103_fpDivTest_q;

    -- xOut(GPOUT,4)@6
    q <= divR_uid110_fpDivTest_q;

END normal;
