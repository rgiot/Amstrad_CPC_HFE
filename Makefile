generate_hfe:
	python manage_discs.py



CPCXFER?=../cpcxfer/xfer
CPCIP?=192.168.1.27
copy_to_m4_sd:
	$(CPCXFER) -u $(CPCIP) ./DSK /
