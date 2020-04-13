Class {
	#name : #JollyLib,
	#superclass : #Object,
	#category : #'Jolly-Libraries'
}

{ #category : #including }
JollyLib class >> beIncludedTo: assembler [
	^ self generateOn: assembler
]

{ #category : #generating }
JollyLib class >> generateOn: assembly [
	^ self new
		generateOn: assembly;
		yourself
]

{ #category : #including }
JollyLib >> beIncludedTo: assembler [
	self generateOn: assembler
]

{ #category : #'code generation' }
JollyLib >> generateGetCharFromStdinOn: assembly [
	"Gets a character from stdin.
	 The 3 bytes at the top of the data stack encode the address to store the resulting character.
	 Stack top -> low-byte of the address
	              middle-byte of the address
	              high-byte of the address
	"
	assembly
		label: #get_char_from_stdin;
		popFromDataStack: #F;
		popFromDataStack: #E;
		popFromDataStack: #D;
		"Backup A,B,C"
		pushOnDataStack: #A;
		pushOnDataStack: #B;
		pushOnDataStack: #C;
		move: #D to: #A;
		move: #E to: #B;
		move: #F to: #C;
		atAddressStoreData: 0; "stdin stream code."
		"Restore A,B,C"
		move: #A to: #D;
		move: #B to: #E;
		move: #C to: #F;
		popFromDataStack: #C;
		popFromDataStack: #B;
		popFromDataStack: #A;
		"Pass arguments to get_char"
		pushOnDataStack: #D;
		pushOnDataStack: #E;
		pushOnDataStack: #F;
		call: #get_char;
		return
]

{ #category : #'code generation' }
JollyLib >> generateGetCharOn: assembly [
	"Gets a character from a stream.
	 The 3 bytes at the top of the data stack encode the address to store the resulting character.
	 Before primitive execution, the stream id is stored at address provided as argument.
	 Stack top -> low-byte of the address
	              middle-byte of the address
	              high-byte of the address
	"
	assembly
		label: #get_char;
		popFromDataStack: #F;
		popFromDataStack: #E;
		popFromDataStack: #D;
		move: #D to: #PRIMITIVE_RESULT_HIGH;
		move: #E to: #PRIMITIVE_RESULT_MIDDLE;
		move: #F to: #PRIMITIVE_RESULT_LOW;
		"3 = get_char primitive id"
		move: 3 to: #PRIMITIVE_CALL_ID;
		"Trigger primitive."
		move: 1 to: #PRIMITIVE_IS_READY;
		return
]

{ #category : #generating }
JollyLib >> generateOn: assembly [
	self
		generateGetCharOn: assembly;
		generateGetCharFromStdinOn: assembly;
		generatePutCharOn: assembly;
		generatePrintStringOn: assembly;
		generateStopVMOn: assembly
]

{ #category : #'code generation' }
JollyLib >> generatePrintStringOn: assembly [
	"Prints a null-terminated ASCII string to stdout.
	 The 3 bytes at the top of the data stack encode the address of the string.
	 Stack top -> A : high-byte of the address
	              B : middle-byte of the address
	              C : low-byte of the address
	"
	assembly
		label: #print_string;
		"Get A,B,C"
		popFromDataStack: #C;
		popFromDataStack: #B;
		popFromDataStack: #A;
		"But keep them on the stack."
		increment: #SP;
		increment: #SP;
		increment: #SP;
		
		label: #print_loop;
		fetchDataAtAddressInto: #G;
		cmp: #G with: Character null asciiValue;
		jumpIfEqual: #print_finished;
		"Prepare args of #put_char"
		pushOnDataStack: 0; "Stdout filestream."
		pushOnDataStack: #A;
		pushOnDataStack: #B;
		pushOnDataStack: #C;
		"Put the char."
		call: #put_char;
		"Set pointer to next_char."
		incrementAddress;
		jump: #print_loop;
		
		label: #print_finished;
		"Restore A,B,C"
		popFromDataStack: #C;
		popFromDataStack: #B;
		popFromDataStack: #A;
		return
]

{ #category : #'code generation' }
JollyLib >> generatePutCharOn: assembly [
	"Puts a character to stdout.
	 The 3 bytes at the top of the data stack encode the address of the character.
	 The byte under the 3 address bytes encode the id of the filestream to the character on.
	 Stack top -> low-byte of the address
	              middle-byte of the address
	              high-byte of the address
	              filestream id
	"
	assembly label: #put_char;
		jump: #_put_char_begin;
		label: #_put_char_pointer;
		data: #[0]; "1 byte for the character to put."
		label: #_put_char_stream_id;
		data: #[0]; "1 byte for the id of the filestream."
		
		label:  #_put_char_begin;
		
		"1. copy the char to print to #_put_char_pointer data location."
		"Get char to print in D"
		fetchDataAtAddressAtDataStackTopInto: #D;
		"Clear the stack from 3 first arguments."
		decrement: #SP; decrement: #SP; decrement: #SP;
		"Backup A,B,C"
		pushOnDataStack: #A;
		pushOnDataStack: #B;
		pushOnDataStack: #C;
		"Get address of#_put_char_pointer "
		pushAddressOfLabelOnDataStack: #_put_char_pointer;
		popFromDataStack: #C;
		popFromDataStack: #B;
		popFromDataStack: #A;
		atAddressStoreData: #D;
		"In the way, set pointer to primitive results."
		move: #A to: #PRIMITIVE_RESULT_HIGH;
		move: #B to: #PRIMITIVE_RESULT_MIDDLE;
		move: #C to: #PRIMITIVE_RESULT_LOW;
		"Get filestream id."
		decrement: #SP; decrement: #SP; decrement: #SP;
		popFromDataStack: #D;
		increment: #SP; increment: #SP; increment: #SP; increment: #SP;
		incrementAddress;
		atAddressStoreData: #D;
		"Restore A,B,C"
		popFromDataStack: #C;
		popFromDataStack: #B;
		popFromDataStack: #A;
		"Clear filestream id from the stack."
		decrement: #SP;
		"2 = put_char primitive id"
		move: 2 to: #PRIMITIVE_CALL_ID;
		"Trigger primitive."
		move: 1 to: #PRIMITIVE_IS_READY;
		return
]

{ #category : #'code generation' }
JollyLib >> generateStopVMOn: assembly [
	assembly
		label: #stop_vm;
		"4 = stop_vm"
		move: 4 to: #PRIMITIVE_CALL_ID;
		"Trigger primitive."
		move: 1 to: #PRIMITIVE_IS_READY
]
