Extension { #name : #BPRegister }

{ #category : #'*Jolly-Assembler' }
BPRegister >> asDirectAccess [
	^ JollyDirectDataAccess address: self
]
