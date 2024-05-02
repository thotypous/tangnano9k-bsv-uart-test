run: reference_data.bin
	python acquire.py
	python sync.py
	vbindiff synced_data.bin reference_data.bin

reference_data.bin: lfsr.py
	python lfsr.py

clean:
	rm *.bin
