import re
from queue import PriorityQueue
from collections import defaultdict



#read input file into a 2D list
def processInput():
	inputFile = input("typing input file name: ")
	f = open(inputFile, "r")
	lines = f.read().splitlines()
	twoDlist = []
	for line in lines:

		if len(line) == 0 or line[0] == '/':
			continue
		#print(line)
		line = line.replace(" ", "")
		#line = line.replace(",", '\t')
		#print(line)
		l = re.split(',|\n|\t',line)
		if len(l) <= 1:
			continue
		
		l = [i for i in l if i]
		twoDlist.append(l)
	return twoDlist


#calculate exit time of each original register
def getLifeTime(twoD):
	lifetimeDict = defaultdict(int)

	for i in range(len(twoD)):
		currInstr = twoD[i]
		for op in currInstr:
			if op[0] != 'r':
				continue
			if op == '=>' and currInstr[0] != 'store':
				break
			if i > lifetimeDict[op]:
				lifetimeDict[op] = i
	return lifetimeDict



def bottom_up(twoD, kReg):
	newProgram = []
	priority0 = len(twoD)
	lifetimeDict = getLifeTime(twoD)
	
	#using a dict to store priority of registers. The higher one will be used first
	q = dict()
	for i in range(1,kReg+1):
		q['r'+str(i)] = priority0
		
	#mapping to the registers in original program.
	old_new_map = defaultdict(lambda: '0')
	new_old_map = dict()
	old_spill_map = defaultdict(lambda: '0')
	spill_old_map = defaultdict(lambda: '0')

	#reading instructions and replacing registers
	for i in range(len(twoD)):
		currInstr = twoD[i]
		newInstr = []

		# TOD: be careful with the case:
		# op ra, rb => ra
		# op ra, ra => ra
		# r3=>ra
		# op r1, r2 => r3
		for op in currInstr:
			if op[0] != 'r':
				newInstr.append(op)
			else:
				#op is a register
				#op already mapped to a register
				if old_new_map[op] != '0':
					newInstr.append(old_new_map[op])
					#check if this is the last call of register, yes:this register has the highest priority
					if i >= lifetimeDict[op] and i != len(twoD)-1:
						q[old_new_map[op]] = priority0+1

				else:
					#op did not mapped to a register or spill address
					#getting a new register
					newReg = max(q, key=q.get)
					newInstr.append(newReg)
					
					#spilling happens, insert a store instruction and the current processing instruction
					if q[newReg] < priority0:
						#getting avaiable spilling address
						spillCandidate = '0'
						for j in range(4, 1028, 4):
							if spill_old_map[str(j)] == '0':
								spillCandidate = str(j)
								break
								#TOD: if load happen, need to update this mapping
						#spillCode = ['store', newReg, '=>' ,'f'+spillCandidate]
						spillCode = ['store', newReg, '=>' ,spillCandidate]
						newProgram.append(['storing to a spilling address'])
						newProgram.append(spillCode)
						#update corresponding mappins. data in new_old_map[newReg] is now saved to spilling address
						spill_old_map[spillCandidate] = new_old_map[newReg] 
						old_spill_map[new_old_map[newReg]] = spillCandidate
						old_new_map[new_old_map[newReg]] = '0'
						
					#it is possible that we save a data to spill address and use this register for load spilling data
					#check if this data is in a spilling address, yes: load first; no: direct map old register to new register
					elif old_spill_map[op] != '0' and old_new_map[op] == '0':
						spilladdress = old_spill_map[op]
						newProgram.append(['loading from a spilling address'])
						#spillcode = ['load', 'f'+spilladdress , '=>' , newReg]
						spillcode = ['load', spilladdress , '=>' , newReg]
						newProgram.append(spillcode)
						old_spill_map[op] = '0'
						spill_old_map[spilladdress] = '0'

					#update the priority of new register
					q[newReg] = lifetimeDict[op]

					#udpate mapping
					old_new_map[op] = newReg
					new_old_map[newReg] = op
		newProgram.append(newInstr)
					

	return newProgram

	

#update the priority of queue by the life time as well such that register reuse
#be careful about the load and store do not remove data. 
#be smart with checking register life time
if __name__ == "__main__":

	twoD = processInput()
	for l in twoD:
		print(l)

	kReg = 3

	print('==================')
	newProgram = bottom_up(twoD, kReg)
	for l in newProgram:
		print(l)






