import os



def read_input(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    inputs = []
    for line in lines:
        for x in line.split():
            inputs.append(int(x))

    return inputs


def arrange_input_hex(inputs, file_path):
    hex_inputs = [hex(x & 0xFF)[2:].zfill(2) for x in inputs]  # Convert to hexadecimal and pad to two digits
    hex_inputs = ''.join(hex_inputs)  # Convert to a string
    
    hex_lines = []
    for i in range(200):
        hex_inputs_line = []
        hex_inputs_line.append(hex_inputs[3*i])
        hex_inputs_line.append(hex_inputs[3*i+1])
        hex_inputs_line.append(hex_inputs[3*i+2])
        hex_lines.append(''.join(hex_inputs_line))  # Concatenate one row of weights into a single string

    with open(file_path, 'w') as file:
        for line in hex_lines:
            file.write(line + '\n')


current_path = os.path.dirname(__file__)
input = read_input(os.path.join(current_path, 'Input.txt'))

arrange_input_hex(input, os.path.join(current_path, 'Input_hex.txt'))
