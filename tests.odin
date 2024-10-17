package test

import "core:fmt"
import "core:os"
print :: fmt.println
printf :: fmt.printf

main :: proc() {

	//=============================================================================================
	// To execute simply type:
	// ./odin_tests.exe C:\Users\mikec\AppData\Local\bin\NASM\listing_0038_many_register_mov
	// or
	// ./odin_tests.exe C:\Users\mikec\AppData\Local\bin\NASM\listing_0037_single_register_mov
	//=============================================================================================

	if len(os.args) > 1 {
		read_file_by_lines_in_whole(os.args[1])
	}

	// necessary hack
	free_all(context.temp_allocator)
}

read_file_by_lines_in_whole :: proc(filepath: string) {
	if data, ok := os.read_entire_file(filepath, context.temp_allocator); ok {
		// defer delete(data)

		for i := 0; i < len(data); i += 2 {

			//! NOTE: This is 'mov cx, bx'
			//! [10001001, 11011001]
			// very helpful for figuring this whole thing out

			// define masks and then 'bitwise &' them with their corresponding data 
			// (e.g data[0]) to see if the result is a 0 or a 1
			mask_opcode :: 0b11111100
			bit_7 :: 0b00000010
			bit_8 :: 0b00000001
			OPCODE := data[i] & mask_opcode // OPCODE is 100010 => MOV
			D := data[i] & bit_7 // D => 0
			W := data[i] & bit_8 // W => 1

			mask_MOD :: 0b11000000
			mask_REG :: 0b00111000
			mask_RM :: 0b00000111
			MOD := data[i + 1] & mask_MOD
			REG := data[i + 1] & mask_REG // REG is 011 and W_bit is 1 => BX
			RM := data[i + 1] & mask_RM // RM is 001 and W_bit is 1 => CX

			instruction := ""
			if OPCODE == 0b100010_00 {
				instruction = "MOV"
			}

			val0 := ""

			if REG == 0b00_000_000 && W == 0 do val0 = "AL"
			else if REG == 0b00_000_000 && W == 1 do val0 = "AX"
			else if REG == 0b00_001_000 && W == 0 do val0 = "CL"
			else if REG == 0b00_001_000 && W == 1 do val0 = "CX"
			else if REG == 0b00_010_000 && W == 0 do val0 = "DL"
			else if REG == 0b00_010_000 && W == 1 do val0 = "DX"
			else if REG == 0b00_011_000 && W == 0 do val0 = "BL"
			else if REG == 0b00_011_000 && W == 1 do val0 = "BX"
			else if REG == 0b00_100_000 && W == 0 do val0 = "AH"
			else if REG == 0b00_100_000 && W == 1 do val0 = "SP"
			else if REG == 0b00_101_000 && W == 0 do val0 = "CH"
			else if REG == 0b00_101_000 && W == 1 do val0 = "BP"
			else if REG == 0b00_110_000 && W == 0 do val0 = "DH"
			else if REG == 0b00_110_000 && W == 1 do val0 = "SI"
			else if REG == 0b00_111_000 && W == 0 do val0 = "BH"
			else if REG == 0b00_111_000 && W == 1 do val0 = "DI"

			val := ""
			// if MOD == 11
			if MOD == 0b11000000 {
				if RM == 0b00_000_000 && W == 0 do val = "AL"
				else if RM == 0b00_000_000 && W == 1 do val = "AX"
				else if RM == 0b00_000_001 && W == 0 do val = "CL"
				else if RM == 0b00_000_001 && W == 1 do val = "CX"
				else if RM == 0b00_000_010 && W == 0 do val = "DL"
				else if RM == 0b00_000_010 && W == 1 do val = "DX"
				else if RM == 0b00_000_011 && W == 0 do val = "BL"
				else if RM == 0b00_000_011 && W == 1 do val = "BX"
				else if RM == 0b00_000_100 && W == 0 do val = "AH"
				else if RM == 0b00_000_100 && W == 1 do val = "SP"
				else if RM == 0b00_000_101 && W == 0 do val = "CH"
				else if RM == 0b00_000_101 && W == 1 do val = "BP"
				else if RM == 0b00_000_110 && W == 0 do val = "DH"
				else if RM == 0b00_000_110 && W == 1 do val = "SI"
				else if RM == 0b00_000_111 && W == 0 do val = "BH"
				else if RM == 0b00_000_111 && W == 1 do val = "DI"
			}

			//* NOTE: If the D field is zero, it means the REG field is NOT the destination.
			source := ""
			destination := ""
			if D == 0 {
				source = val0
				destination = val
			} else if D == 1 {
				source = val
				destination = val0
			}

			// print final assemby instruction
			printf("%s %s, %s \n", instruction, destination, source)
		}
	}
}
