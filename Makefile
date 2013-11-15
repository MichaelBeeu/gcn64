AVRA=avra
AVRDUDE=avrdude

BINDIR=Debug

IC=attiny2313
PORT=/dev/ttyACM0
PROTO=avrispv2
BAUD=115200

AVRDUDEFLAGS=-v
AVRAFLAGS=-I /usr/share/avra

PROJNAME=$(shell basename `pwd`)
TARGET=$(BINDIR)/$(PROJNAME).hex

all: $(TARGET)

flash: all
	$(AVRDUDE) -p$(IC) -P$(PORT) -c$(PROTO) -b$(BAUD) -Uflash:w:$(TARGET) $(AVRDUDEFLAGS)

clean:
	rm -f $(BINDIR)/$(PROJNAME).cof $(BINDIR)/$(PROJNAME).eep.hex $(BINDIR)/$(PROJNAME).obj $(TARGET) 

$(BINDIR)/%.hex : %.asm
	-mkdir -p $(dir $@)
	# For some reason AVRA doesn't acknowledge the output directory
	# and will place output files in the basepath of the source file
	-ln -s ../$< $(dir $@)$<
	cd $(dir $@) ; $(AVRA) $(AVRAFLAGS) -I ../ -o $@ $<
	-rm $(dir $@)$<

.PHONY: all
