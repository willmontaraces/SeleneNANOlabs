# index calcular for ahb_latency_and_contention.vhd
ncpu=6; # Number of cores
nout=256; # maximum number of signals
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
        print(" "+str(gi)+" & "+"CCS AHB & "+" - "+" & "+ " Contention C"+str(csource)+" over C"+str(cvic)+"\\\\")
        print("\hline ")

for n in range(gi,nout-1,1):
    gi=gi+1; 
    print(" "+str(gi)+" & "+"- & "+"- & "+"  Filler signal, constant 0 \\\\")
    print("\hline ")

print("======================== LATEX ===============");
print("======================== 6 CORES ===============");
print("======================== LATEX ===============");

ncpu=6; # Number of cores
nout=256; # maximum number of signals
print("\hline")
print(" "+str(0)+" & "+"Debug & "+"local & "+" Constant HIGH, used for debug purposes or clock cycles \\\\")
###print("\hline ")
print(" "+str(1)+" & "+"Debug & "+"local & "+" Constant LOW, used for debug purposes \\\\")
###print("\hline ")
for I in range(ncpu-1+1):
        gi=(I*7)
        print(" "+str(gi+2)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Instruction count pipeline 0 \\\\")
        ###print("\hline ")
        print(" "+str(gi+3)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Instruction count pipeline 1 \\\\")
        ###print("\hline ")
        print(" "+str(gi+4)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Instruction cache miss \\\\")
        ###print("\hline ")
        print(" "+str(gi+5)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Instruction TLB miss \\\\")
        ###print("\hline ")
        print(" "+str(gi+6)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Data chache L1 miss \\\\")
        ###print("\hline ")
        print(" "+str(gi+7)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Data TLB miss \\\\")
        ###print("\hline ")
        print(" "+str(gi+8)+" & "+"Pulse & "+"Core "+str(I)+" & "+" Branch predictor miss \\\\")
        ###print("\hline ")

for n in range(ncpu-1+1):
    for I in range(ncpu-2+1):
        gi=(n*(ncpu-1)+I+((ncpu-1)*7+8)+1)
        ccsi=(n*(ncpu-1)+I)
        ## get contention source and victim
        cvic=n
        if(n>I):
            csource=I
        else:
            csource=I+1
        print(" "+str(gi)+" & "+"CCS AHB & "+" - "+" & "+ " Agressor C"+str(csource)+" Victim C"+str(cvic)+"\\\\")
        ###print("\hline ")
## CCS AXI R
nqos=15 #N QoS L2,accelerator,empty?, empty?
MEM_SNIFF_CORES_VECTOR_DEEP_USED = nqos
victims=ncpu
BASE_BASIC = 0;                                                                 
END_BASIC =(ncpu-1)*7+8;                                                        
BASE_CCS_AHB=END_BASIC+1;                                                       
END_CCS_AHB=END_BASIC+(ncpu-1)*(ncpu-1)+(ncpu-2)+1;                             
BASE_CCS_AXI_W =END_CCS_AHB+1;                               
END_CCS_AXI_W =(victims*(MEM_SNIFF_CORES_VECTOR_DEEP_USED -1)) + BASE_CCS_AXI_W-1
BASE_CCS_AXI_R =END_CCS_AXI_W+1;                                                
END_CCS_AXI_R = END_CCS_AXI_W +(MEM_SNIFF_CORES_VECTOR_DEEP_USED -1)*(MEM_SNIFF_CORES_VECTOR_DEEP_USED -1)+(MEM_SNIFF_CORES_VECTOR_DEEP_USED-2)
END_CCS_AXI_R =(victims*(MEM_SNIFF_CORES_VECTOR_DEEP_USED -1)) + BASE_CCS_AXI_R -1

n=MEM_SNIFF_CORES_VECTOR_DEEP_USED -1
I=MEM_SNIFF_CORES_VECTOR_DEEP_USED -2
END_CCS_AXI=n*(MEM_SNIFF_CORES_VECTOR_DEEP_USED -1)+ I + END_CCS_AHB 

gi=END_CCS_AHB;
for n in range(victims-1+1):
    for I in range(nqos-2+1):
        gi=gi+1
        ccsi=(n*(nqos-2)+I)
        ## get contention source and victim
        cvic=n
        if(n>I):
            csource=I
        else:
            csource=I+1
        print(" "+str(gi)+" & "+"CCS AXI & "+"Write"+" & "+ " Agressor MQ"+str(csource)+" Victim MQ"+str(cvic)+"\\\\")
        ###print("\hline ")
## CCS AXI W
for n in range(victims-1+1):
    for I in range(nqos-2+1):
        gi=gi+1
        ccsi=(n*(nqos-1)+I)
        ## get contention source and victim
        cvic=n
        if(n>I):
            csource=I
        else:
            csource=I+1
        print(" "+str(gi)+" & "+"CCS AXI & "+"Read"+" & "+ " Agressor MQ"+str(csource)+" Victim MQ"+str(cvic)+"\\\\")
        ###print("\hline ")

## FILLER
for n in range(gi,nout-1,1):
    gi=gi+1; 
    print(" "+str(gi)+" & "+"- & "+"- & "+"  Filler signal, constant 0 \\\\")
    ###print("\hline ")
"""
%nogpl
0 & AHB & 0 &  NOEL-V CORE \\
1 & AHB & 1 &  NOEL-V CORE \\
2 & AHB & 2 &  NOEL-V CORE \\
3 & AHB & 3 &  NOEL-V CORE \\
4 & AHB & 4 &  NOEL-V CORE \\
5 & AHB & 5 &  NOEL-V CORE \\

6 & AHB & 6 &  GR Ethernet MAC \\
7 & AHB & 7 &  GRSPW2 SpaceWire \\
8 & AHB & 8 &  GRSPW2 SpaceWire \\
9 & AHB & 9 &  CAN-FD Controller with DMA \\
10 & AHB & 10 &  CAN-FD Controller with DMA \\
11 & AHB & 11 & GRDMAC2 DMA Controller \\
12 & AHB & 12 & AHB Debug UART  \\
13 & AHB & 13 & JTAG Debug Link   \\
14 & AHB & 14 & EDCL master interface  \\

%%GPL

0 & AHB & 0 &  NOEL-V CORE \\
1 & AHB & 1 &  NOEL-V CORE \\
2 & AHB & 2 &  NOEL-V CORE \\
3 & AHB & 3 &  NOEL-V CORE \\
4 & AHB & 4 &  NOEL-V CORE \\
5 & AHB & 5 &  NOEL-V CORE \\
6 & AHB & 6 &  GR Ethernet MAC \\
7 & AHB & 7 &  GRDMAC2 DMA Controller \\
8 & AHB & 8 &  AHB Debug UART \\
9 & AHB & 9 &  JTAG Debug Link \\
10 & AHB & 10 &  EDCL master interface   \\
"""
