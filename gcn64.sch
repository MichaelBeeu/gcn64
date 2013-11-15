EESchema Schematic File Version 2  date Fri 15 Nov 2013 02:12:31 AM CST
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:special
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
EELAYER 43  0
EELAYER END
$Descr A4 11700 8267
encoding utf-8
Sheet 1 1
Title ""
Date "15 nov 2013"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Notes 7350 7550 0    60   ~ 0
gcn64
Wire Wire Line
	5650 1200 5650 1000
Wire Wire Line
	5650 1000 5950 1000
Wire Wire Line
	2300 1200 2300 1350
Wire Wire Line
	6400 2400 6400 2300
Connection ~ 6400 3100
Wire Wire Line
	6600 3100 5700 3100
Wire Wire Line
	4850 3100 5200 3100
Wire Wire Line
	3700 3700 3700 3850
Wire Wire Line
	1300 650  1300 700 
Wire Wire Line
	1300 700  1100 700 
Wire Wire Line
	1100 1000 1300 1000
Wire Wire Line
	1300 1000 1300 1200
Wire Wire Line
	3700 1350 3700 1600
Wire Wire Line
	2300 1850 2300 1900
Wire Wire Line
	2300 1900 2550 1900
Wire Wire Line
	6400 3100 6400 2900
Wire Wire Line
	6600 3000 4850 3000
Connection ~ 5900 3000
Wire Wire Line
	5900 2500 5900 2300
Wire Wire Line
	5600 700  5600 800 
Wire Wire Line
	5600 800  5950 800 
$Comp
L +3.3V #PWR01
U 1 1 5285D62E
P 5600 700
F 0 "#PWR01" H 5600 660 30  0001 C CNN
F 1 "+3.3V" H 5600 810 30  0000 C CNN
	1    5600 700 
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR02
U 1 1 5285D62B
P 5650 1200
F 0 "#PWR02" H 5650 1200 30  0001 C CNN
F 1 "GND" H 5650 1130 30  0001 C CNN
	1    5650 1200
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR03
U 1 1 5285D614
P 2300 1200
F 0 "#PWR03" H 2300 1160 30  0001 C CNN
F 1 "+3.3V" H 2300 1310 30  0000 C CNN
	1    2300 1200
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR04
U 1 1 5285D5EC
P 6400 2300
F 0 "#PWR04" H 6400 2260 30  0001 C CNN
F 1 "+3.3V" H 6400 2410 30  0000 C CNN
	1    6400 2300
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR05
U 1 1 5285D5E0
P 5900 2300
F 0 "#PWR05" H 5900 2260 30  0001 C CNN
F 1 "+3.3V" H 5900 2410 30  0000 C CNN
	1    5900 2300
	1    0    0    -1  
$EndComp
$Comp
L R R3
U 1 1 5285D52F
P 5900 2750
F 0 "R3" V 5980 2750 50  0000 C CNN
F 1 "1k" V 5900 2750 50  0000 C CNN
	1    5900 2750
	1    0    0    -1  
$EndComp
$Comp
L R R2
U 1 1 5285D52B
P 5450 3100
F 0 "R2" V 5530 3100 50  0000 C CNN
F 1 "220" V 5450 3100 50  0000 C CNN
	1    5450 3100
	0    1    1    0   
$EndComp
$Comp
L R R4
U 1 1 5285D528
P 6400 2650
F 0 "R4" V 6480 2650 50  0000 C CNN
F 1 "1k" V 6400 2650 50  0000 C CNN
	1    6400 2650
	1    0    0    -1  
$EndComp
$Comp
L R R1
U 1 1 5285D51C
P 2300 1600
F 0 "R1" V 2380 1600 50  0000 C CNN
F 1 "4.7k" V 2300 1600 50  0000 C CNN
	1    2300 1600
	1    0    0    -1  
$EndComp
Text GLabel 6600 3100 2    60   BiDi ~ 0
GC_DATA
Text GLabel 5950 1000 2    60   Input ~ 0
GC_GND
Text GLabel 5950 800  2    60   Output ~ 0
GC_VCC
$Comp
L +3.3V #PWR06
U 1 1 5285D475
P 3700 1350
F 0 "#PWR06" H 3700 1310 30  0001 C CNN
F 1 "+3.3V" H 3700 1460 30  0000 C CNN
	1    3700 1350
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR07
U 1 1 5285D470
P 3700 3850
F 0 "#PWR07" H 3700 3850 30  0001 C CNN
F 1 "GND" H 3700 3780 30  0001 C CNN
	1    3700 3850
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR08
U 1 1 5285D457
P 1300 1200
F 0 "#PWR08" H 1300 1200 30  0001 C CNN
F 1 "GND" H 1300 1130 30  0001 C CNN
	1    1300 1200
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR09
U 1 1 5285D44F
P 1300 650
F 0 "#PWR09" H 1300 610 30  0001 C CNN
F 1 "+3.3V" H 1300 760 30  0000 C CNN
	1    1300 650 
	1    0    0    -1  
$EndComp
Text GLabel 1100 1000 0    60   Output ~ 0
N64_GND
Text GLabel 6600 3000 2    60   BiDi ~ 0
N64_DATA
Text GLabel 1100 700  0    60   Input ~ 0
N64_VCC
$Comp
L ATTINY2313-P IC1
U 1 1 5285D3EF
P 3700 2700
F 0 "IC1" H 2850 3650 60  0000 C CNN
F 1 "ATTINY2313-P" H 4300 1850 60  0000 C CNN
F 2 "DIP20" H 2900 1850 60  0001 C CNN
	1    3700 2700
	1    0    0    -1  
$EndComp
$EndSCHEMATC
