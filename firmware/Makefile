help:
	@echo "make targets"
	@echo "    bootconf.txt        generate a patched config from firmware"
	@echo "    update              burn the firmware"


# BOOT_ORDER=0x12	pxe / sd
# TFTP_PREFIX=2		use MAC not serial number

bootconf.txt:
	sudo apt install rpi-eeprom
	rpi-eeprom-config pieeprom-*.bin | awk '/BOOT_ORDER/ { print "BOOT_ORDER=0x12"; next } /TFTP_PREFIX/ { print "TFTP_PREFIX=2"; next } { print }' > $@

firmware.bin: bootconf.txt
	rpi-eeprom-config --out $@ --config $< pieeprom-*.bin

update: firmware.bin
	sudo rpi-eeprom-update -d -f ./$<

clean:
	-rm bootconf.txt
	-rm firmware.bin
