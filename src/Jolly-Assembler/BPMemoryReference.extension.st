Extension { #name : #BPMemoryReference }

{ #category : #'*Jolly-Assembler' }
BPMemoryReference >> asDirectAccess [
	^ JollyDirectDataAccess address: self
]
