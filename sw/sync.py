with open('acquired_data.bin', 'rb') as f:
    acquired_data = f.read()

with open('reference_data.bin', 'rb') as f:
    reference_data = f.read()

sync_sequence = reference_data[:4]

start = acquired_data.find(sync_sequence)

with open('synced_data.bin', 'wb') as f:
    f.write(acquired_data[start:])
