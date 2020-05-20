Extension { #name : #BPLabelReference }

{ #category : #'*Jolly-Assembler' }
BPLabelReference >> asDirectAccess [
	^ JollyDirectDataAccess address: self
]
