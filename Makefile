
AVRA=avra
AVRDUDE=avrdude

IC=attiny2313
PORT=/dev/ttyACM0
PROTO=arduino
BAUD=115200
AVRDUDEFLAGS=-v

TARGET=gcn64.hex
SOURCES=$(TARGET:.hex=.asm)

all: $(TARGET)

$(TARGET): delay.inc n64.inc gc.inc

clean:
	rm -f $(SOURCES).cof $(SOURCES).eep.hex $(SOURCES).hex $(SOURCES).obj

flash: all
	$(AVRDUDE) -p$(IC) -P$(PORT) -c$(PROTO) -b$(BAUD) -Uflash:w:$(TARGET) $(AVRDUDEFLAGS)

%.hex : %.asm
	$(AVRA) -o $@ $<


