--------------- 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.aux_package.ALL;
-------------- ENTITY --------------------
ENTITY ForwardingUnit IS
	PORT( 
		WriteReg_MEM, WriteReg_WB	: IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		EX_RegRs, EX_RegRt 			: IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		ID_RegRs, ID_RegRt 			: IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		MEM_RegWr, WB_RegWr			: IN  STD_LOGIC;
		MemtoReg_MEM				: IN STD_LOGIC;
		ForwardA, ForwardB			: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		ForwardA_ID, ForwardB_ID	: OUT STD_LOGIC
		);
END 	ForwardingUnit;
------------ ARCHITECTURE ----------------
ARCHITECTURE structure OF ForwardingUnit IS
BEGIN
	PROCESS (WriteReg_MEM, WriteReg_WB, EX_RegRs, EX_RegRt, MEM_RegWr, WB_RegWr)
	BEGIN
	--------------------- Register Forwarding -----------------------
		-- EX Hazard
		IF (MEM_RegWr = '1' AND WriteReg_MEM /= "00000" AND WriteReg_MEM = EX_RegRs)  THEN -- EX Hazard take from MEM
			ForwardA <= "10";
		ELSIF (WB_RegWr = '1' AND WriteReg_WB /= "00000"
			AND (NOT (MEM_RegWr = '1' AND WriteReg_MEM /= "00000"
				AND (WriteReg_MEM = EX_RegRs)))
			AND WriteReg_WB = EX_RegRs) THEN -- MEM Hazard take from WB
			ForwardA <= "01";
		ELSE 
			ForwardA <= "00";	
		END IF;
		
		
		IF (MEM_RegWr = '1' AND WriteReg_MEM /= "00000" AND WriteReg_MEM = EX_RegRt)  THEN -- EX Hazard take from MEM
			ForwardB <= "10";
		ELSIF (WB_RegWr = '1' AND WriteReg_WB /= "00000"
			AND (NOT (MEM_RegWr = '1' AND WriteReg_MEM /= "00000"
				AND (WriteReg_MEM = EX_RegRt)))
			AND WriteReg_WB = EX_RegRt) THEN -- MEM Hazard take from WB
			ForwardB <= "01";
		ELSE 
			ForwardB <= "00";
		END IF;
	-------------- Branch Forwarding --------------------
		IF ( (ID_RegRs /= "00000") AND (ID_RegRs = WriteReg_MEM) AND MEM_RegWr = '1' ) THEN 
			ForwardA_ID <= '1';
		ELSE 
			ForwardA_ID <= '0';
		END IF;
		
		IF ( (ID_RegRt /= "00000") AND (ID_RegRt = WriteReg_MEM) AND MEM_RegWr = '1' ) THEN 
			ForwardB_ID <= '1';
		ELSE 
			ForwardB_ID <= '0';
		END IF;		
	
	
	END PROCESS;

END Structure;