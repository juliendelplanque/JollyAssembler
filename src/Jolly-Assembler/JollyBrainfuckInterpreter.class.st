Class {
	#name : #JollyBrainfuckInterpreter,
	#superclass : #JollyProgram,
	#category : #'Jolly-Assembler'
}

{ #category : #generating }
JollyBrainfuckInterpreter >> generateOn: assembler [
	assembler
	label: #bfcode;
		data: (ByteArray new: 4096);
	label: #bfmemory;
		data: (ByteArray new: 30000);
	label: #bfcodepointer;
		data: #[0 0 0];
	label: #bfpointer;
		data: #[0 0 0];
	label: #brackets_count;
		data: #[0];
	
	label: #_start;
	loadWordFromLabel: #bfcode into: #PRIMITIVE_RESULT_HIGH;
	label: #read_bf_code;
		moveCharFrom: 0 toIndirect: #PRIMITIVE_RESULT_HIGH;
		"Primitive id: get char"
		moveCharFrom: 3 to: #PRIMITIVE_CALL_ID;
		"Trigger primitive."
		moveCharFrom: 1 to: #PRIMITIVE_IS_READY;
		moveCharFromIndirect: #PRIMITIVE_RESULT_HIGH to: #A;
		
		"Check if EOF was encountered."
		cmp: #PRIMITIVE_RESULT_CODE with: 1;
		"If so, start interpreting BF code."
		jumpIfEqual: #interpret_bf_code;
	
		incrementWord: #PRIMITIVE_RESULT_HIGH;
		jump: #read_bf_code;
	
	label: #interpret_bf_code;
	
	loadWordFromLabel: #bfmemory into: #bfpointer;
	loadWordFromLabel: #bfcode into: #bfcodepointer;
	label: #interpret_loop;
		moveCharFromIndirect: #bfcodepointer to: #A;
		"Decode BF instruction."
		cmp: #A with: $> asciiValue;
		jumpIfEqual: #incrementBfpointer;
		
		cmp: #A with: $< asciiValue;
		jumpIfEqual: #decrementBfpointer;
		
		cmp: #A with: $+ asciiValue;
		jumpIfEqual: #incrementBytePointed;
		
		cmp: #A with: $- asciiValue;
		jumpIfEqual: #decrementBytePointed;
		
		cmp: #A with: $. asciiValue;
		jumpIfEqual: #outputByte;
		
		cmp: #A with: $, asciiValue;
		jumpIfEqual: #inputByte;
		
		cmp: #A with: $[ asciiValue;
		jumpIfEqual: #openBracket;
			
		cmp: #A with: $] asciiValue;
		jumpIfEqual: #closeBracket;
		
		cmp: #A with: 0;
		jumpIfEqual: #stop_vm;
	
		"Unknown instruction, ignore it."
		incrementWord: #bfcodepointer;
		jump: #interpret_loop;
	
		label: #incrementBfpointer;
			incrementWord: #bfpointer;
			incrementWord: #bfcodepointer;
			jump: #interpret_loop;
		
		label: #decrementBfpointer;
			decrementWord: #bfpointer;
			incrementWord: #bfcodepointer;
			jump: #interpret_loop;
		
		label: #incrementBytePointed;
			moveCharFromIndirect: #bfpointer to: #F;
			increment: #F;
			moveCharFrom: #F toIndirect: #bfpointer;
			incrementWord: #bfcodepointer;
			jump: #interpret_loop;
		
		label: #decrementBytePointed;
			moveCharFromIndirect: #bfpointer to: #F;
			decrement: #F;
			moveCharFrom: #F toIndirect: #bfpointer;
			incrementWord: #bfcodepointer;
			jump: #interpret_loop;
		
		label: #outputByte;
			moveCharFromIndirect: #bfpointer to: #A;
			moveCharFrom: 1 to: #B; "STDOUT"
			loadWordFrom: (assembler memoryLayout registerNamed: #A) address memoryAddress
			into: #PRIMITIVE_RESULT_HIGH;
			"Primitive id: put char"
			moveCharFrom: 2 to: #PRIMITIVE_CALL_ID;
			"Trigger primitive."
			moveCharFrom: 1 to: #PRIMITIVE_IS_READY;
			incrementWord: #bfcodepointer;
			jump: #interpret_loop;
		
		label: #inputByte;
			"Set stream to read from to be stdin."
			moveCharFrom: 0 to: #A;
			loadWordFrom: (assembler memoryLayout registerNamed: #A) address memoryAddress
			into: #PRIMITIVE_RESULT_HIGH;
			"Primitive id: get char"
			moveCharFrom: 3 to: #PRIMITIVE_CALL_ID;
			"Trigger primitive."
			moveCharFrom: 1 to: #PRIMITIVE_IS_READY;
			moveCharFrom: #A toIndirect: #bfpointer;
			incrementWord: #bfcodepointer;
			jump: #interpret_loop;
			
		label: #openBracket;
			moveCharFrom: 1 to: #brackets_count;
			moveCharFromIndirect: #bfpointer to: #A;
			cmp: #A with: 0;
			jumpIfEqual: #openBracket_zero;
			incrementWord: #bfcodepointer;
			jump: #interpret_loop;
			
			label: #openBracket_zero;
				"Here we need to search for the matching ]"
				"Warning, this first version does not work with nested []"
				incrementWord: #bfcodepointer;
				moveCharFromIndirect: #bfcodepointer to: #A;
				cmp: #A with: $[ asciiValue;
				jumpIfNotEqual: #openBracket_zero_not_open_bracket;
				increment: #brackets_count;
				jump: #openBracket_zero;
				
				label: #openBracket_zero_not_open_bracket;
				cmp: #A with: $] asciiValue;
				jumpIfNotEqual: #openBracket_zero;
				"We found a ], need to see if it is matching one."
				decrement: #brackets_count;
				cmp: #brackets_count with: 0;
				jumpIfNotEqual: #openBracket_zero;
				"Here, we found the matching ], thus we increment the code pointer and continue interpreting."
				incrementWord: #bfcodepointer;
				jump: #interpret_loop;
		
		label: #closeBracket;
			moveCharFrom: 1 to: #brackets_count;
			moveCharFromIndirect: #bfpointer to: #A;
			cmp: #A with: 0;
			jumpIfNotEqual: #closeBracket_nonzero;
			incrementWord: #bfcodepointer;
			jump: #interpret_loop;
			
			label: #closeBracket_nonzero;
				"Here we need to search for the matching ["
				"Warning, this first version does not work with nested []"
				decrementWord: #bfcodepointer;
				moveCharFromIndirect: #bfcodepointer to: #A;
				cmp: #A with: $] asciiValue;
				jumpIfNotEqual: #closeBracket_nonzero_not_close_bracket;
				increment: #brackets_count;
				jump: #closeBracket_nonzero;
				
				label: #closeBracket_nonzero_not_close_bracket;
				cmp: #A with: $[ asciiValue;
				"If instruction is not [, continue search."
				jumpIfNotEqual: #closeBracket_nonzero;
				"We found a [, need to see if it is matching one."
				decrement: #brackets_count;
				cmp: #brackets_count with: 0;
				jumpIfNotEqual: #closeBracket_nonzero;
				"Here move code pointer to instruction just after [ and continue interpreting."
				"incrementWord: #bfcodepointer;"
				jump: #interpret_loop;
	
	
	label: #stop_vm;
		"Stop the VM."
		moveCharFrom: 4 to: #PRIMITIVE_CALL_ID;
		"Trigger primitive."
		moveCharFrom: 1 to: #PRIMITIVE_IS_READY.
]
