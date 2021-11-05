# index calcular for ahb_latency_and_contention.vhd
ncpu=6; # Number of cores
nout=128; # maximum number of signals
print("Index:"+str(0)+" Debug signal, constant 1")
print("Index:"+str(1)+" Debug signal, constant 0")
for I in range(ncpu-1+1):
        gi=(I*7)
        print("Index:"+str(gi+2)+"   Instruction count pipeline 0, Core"+str(ncpu))
        print("Index:"+str(gi+3)+"   Instruction count pipeline 1, Core"+str(ncpu))
        print("Index:"+str(gi+4)+"   Instruction cache miss, Core"+str(ncpu))
        print("Index:"+str(gi+5)+"   Instruction TLB miss, Core"+str(ncpu))
        print("Index:"+str(gi+6)+"   Data chache L1 miss, Core"+str(ncpu))
        print("Index:"+str(gi+7)+"   Data TLB miss, Core"+str(ncpu))
        print("Index:"+str(gi+8)+"   Branch predictor miss, Core"+str(ncpu))

for n in range(ncpu-1+1):
    for I in range(ncpu-2+1):
        gi=(n*(ncpu-1)+I+((ncpu-1)*7+8)+1)
        ccsi=(n*(ncpu-1)+I)
        ## get contention source and victim
        csource=n
        if(n>I):
            cvic=I
        else:
            cvic=I+1
        print("Index:"+str(gi)+"   ccs index"+ str(ccsi)+ "   Contention C"+str(csource)+" over C"+str(cvic))

for n in range(gi,nout-1,1):
    gi=gi+1; 
    print("Index:"+str(gi)+"  Filler signal, constant 0")




print("======================== LATEX ===============");
print("======================== 4 CORES ===============");
print("======================== LATEX ===============");

ncpu=4; # Number of cores
nout=128; # maximum number of signals
print("\hline")
print(" "+str(0)+" & "+"Debug & "+"local & "+" Constant HIGH, used for debug purposes or clock cycles \\\\")
print("\hline ")
print(" "+str(1)+" & "+"Debug & "+"local & "+" Constant LOW, used for debug purposes \\\\")
print("\hline ")
for I in range(ncpu-1+1):
        gi=(I*7)
        print(" "+str(gi+2)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Instruction count pipeline 0 \\\\")
        print("\hline ")
        print(" "+str(gi+3)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Instruction count pipeline 1 \\\\")
        print("\hline ")
        print(" "+str(gi+4)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Instruction cache miss \\\\")
        print("\hline ")
        print(" "+str(gi+5)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Instruction TLB miss \\\\")
        print("\hline ")
        print(" "+str(gi+6)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Data chache L1 miss \\\\")
        print("\hline ")
        print(" "+str(gi+7)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Data TLB miss \\\\")
        print("\hline ")
        print(" "+str(gi+8)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Branch predictor miss \\\\")
        print("\hline ")

for n in range(ncpu-1+1):
    for I in range(ncpu-2+1):
        gi=(n*(ncpu-1)+I+((ncpu-1)*7+8)+1)
        ccsi=(n*(ncpu-1)+I)
        ## get contention source and victim
        csource=n
        if(n>I):
            cvic=I
        else:
            cvic=I+1
        print(" "+str(gi)+" & "+"CCS & "+"Core"+str(I)+" & "+ " Contention C"+str(csource)+" over C"+str(cvic)+"\\\\")
        print("\hline ")

for n in range(gi,nout-1,1):
    gi=gi+1; 
    print(" "+str(gi)+" & "+"- & "+"- & "+"  Filler signal, constant 0 \\\\")
    print("\hline ")

print("======================== LATEX ===============");
print("======================== 6 CORES ===============");
print("======================== LATEX ===============");

ncpu=6; # Number of cores
nout=128; # maximum number of signals
print("\hline")
print(" "+str(0)+" & "+"Debug & "+"local & "+" Constant HIGH, used for debug purposes or clock cycles \\\\")
print("\hline ")
print(" "+str(1)+" & "+"Debug & "+"local & "+" Constant LOW, used for debug purposes \\\\")
print("\hline ")
for I in range(ncpu-1+1):
        gi=(I*7)
        print(" "+str(gi+2)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Instruction count pipeline 0 \\\\")
        print("\hline ")
        print(" "+str(gi+3)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Instruction count pipeline 1 \\\\")
        print("\hline ")
        print(" "+str(gi+4)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Instruction cache miss \\\\")
        print("\hline ")
        print(" "+str(gi+5)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Instruction TLB miss \\\\")
        print("\hline ")
        print(" "+str(gi+6)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Data chache L1 miss \\\\")
        print("\hline ")
        print(" "+str(gi+7)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Data TLB miss \\\\")
        print("\hline ")
        print(" "+str(gi+8)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Branch predictor miss \\\\")
        print("\hline ")

for n in range(ncpu-1+1):
    for I in range(ncpu-2+1):
        gi=(n*(ncpu-1)+I+((ncpu-1)*7+8)+1)
        ccsi=(n*(ncpu-1)+I)
        ## get contention source and victim
        csource=n
        if(n>I):
            cvic=I
        else:
            cvic=I+1
        print(" "+str(gi)+" & "+"CCS & "+"Core"+str(I)+" & "+ " Contention C"+str(csource)+" over C"+str(cvic)+"\\\\")
        print("\hline ")

for n in range(gi,nout-1,1):
    gi=gi+1; 
    print(" "+str(gi)+" & "+"- & "+"- & "+"  Filler signal, constant 0 \\\\")
    print("\hline ")

