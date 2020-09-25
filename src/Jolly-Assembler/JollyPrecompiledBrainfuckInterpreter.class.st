Class {
	#name : #JollyPrecompiledBrainfuckInterpreter,
	#superclass : #JollyBrainfuckInterpreterIntensivePrimitiveUsage,
	#category : #'Jolly-Assembler'
}

{ #category : #generating }
JollyPrecompiledBrainfuckInterpreter >> generateCompileBfCodeOn: assembler [
	assembler
	label: #_start;
	
	"Fetch input characters into register A."
	loadWordFromLabel: #A into: #PRIMITIVE_RESULT_HIGH;
	loadWordFromLabel: #bfcode into: #bfcodepointer;
	label: #compile_bf_code;
		moveCharFrom: 0 toIndirect: #PRIMITIVE_RESULT_HIGH;
		"Primitive id: get char"
		moveCharFrom: 3 to: #PRIMITIVE_CALL_ID;
		"Trigger primitive."
		moveCharFrom: 1 to: #PRIMITIVE_IS_READY;
		
		"Decode instruction."
		cmp: #A with: $> asciiValue;
		jumpIfEqual: #compileIncrementBfpointer;
		
		cmp: #A with: $< asciiValue;
		jumpIfEqual: #compileDecrementBfpointer;
		
		cmp: #A with: $+ asciiValue;
		jumpIfEqual: #compileIncrementBytePointed;
		
		cmp: #A with: $- asciiValue;
		jumpIfEqual: #compileDecrementBytePointed;
		
		cmp: #A with: $. asciiValue;
		jumpIfEqual: #compileOutputByte;
		
		cmp: #A with: $, asciiValue;
		jumpIfEqual: #compileInputByte;
		
		cmp: #A with: $[ asciiValue;
		jumpIfEqual: #compileOpenBracket;
			
		cmp: #A with: $] asciiValue;
		jumpIfEqual: #compileCloseBracket;
		
		"Check if EOF was encountered."
		cmp: #PRIMITIVE_RESULT_CODE with: 1;
		"If so, start interpreting BF code."
		jumpIfEqual: #interpret_bf_code;
	
		"If none of previous characters match, ignore input."
		jump: #compile_bf_code;
		
		label: #compileIncrementBfpointer;
			moveCharFromIndirect: #bfcodepointer to: #E;
			"Check if previous character was also a '>'"
			cmp: #E with: $> asciiValue;
			jumpIfEqual: #incrementParameterOfPlusInstruction;
			
			"Here we move the code pointer 3 bytes after current position
			 and we create the bytecode for the instruction.
			"
			primitiveIncrementWord: #bfcodepointer;
			primitiveIncrementWord: #bfcodepointer;
			primitiveIncrementWord: #bfcodepointer;
			moveCharFrom: $> asciiValue toIndirect: #bfcodepointer;
			primitiveIncrementWord: #bfcodepointer;
			moveCharFrom: 0 toIndirect: #bfcodepointer;
			primitiveIncrementWord: #bfcodepointer;
			moveCharFrom: 0 toIndirect: #bfcodepointer;
			primitiveIncrementWord: #bfcodepointer;
			moveCharFrom: 1 toIndirect: #bfcodepointer;
			primitiveDecrementWord: #bfcodepointer;
			primitiveDecrementWord: #bfcodepointer;
			primitiveDecrementWord: #bfcodepointer;
			label: #debug1;
			jump: #compile_bf_code;
			
			label: #incrementParameterOfPlusInstruction;
			"Here, as previous instruction was already a '>', we just
			 increment the parameter so it has the desired effect.
			"
			primitiveIncrementWord: #bfcodepointer;
			moveWordFromIndirect: #bfcodepointer to: #F;
			primitiveIncrementWord: #F;
			moveWordFrom: #F toIndirect: #bfcodepointer;
			primitiveDecrementWord: #bfcodepointer;
			label: #debug2;
			jump: #compile_bf_code;
			
		label: #compileDecrementBfpointer;
			"flag: #TODO;"
		label: #compileIncrementBytePointed;
			"flag: #TODO;"
		label: #compileDecrementBytePointed;
			"flag: #TODO;"
		label: #compileInputByte;
			"flag: #TODO;"
		label: #compileOutputByte;
			"flag: #TODO;"
		label: #compileOpenBracket;
			"flag: #TODO;"
		label: #compileCloseBracket
			"flag: #TODO".
]

{ #category : #generating }
JollyPrecompiledBrainfuckInterpreter >> generateInterpretBfCodeOn: assembler [
	assembler
	label: #interpret_bf_code;
	moveCharFrom: 0 toIndirect: #PRIMITIVE_RESULT_HIGH;
	
	loadWordFromLabel: #bfmemory into: #bfpointer;
	loadWordFromLabel: #bfcode into: #bfcodepointer;
	label: #interpret_loop;
		flag: #TODO
]
