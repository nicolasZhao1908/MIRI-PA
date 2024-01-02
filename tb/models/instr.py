"""
Helper module for creating RISC-V instructions hexadecimal representation
"""

def addi(rd, rs1, imm, newline=True):
    """
    ADDI rd, rs1, imm
    """
    opcode = 0b0010011
    funct3 = 0b000

    instr = f"{imm:012b}{rs1:05b}{funct3:03b}{rd:05b}{opcode:07b}"
    instr = f"{int(instr,2):08x}"

    if newline:
        instr += "\n"

    return instr

def add(rd, rs1, rs2, newline = True):
    """
    ADD rd, rs1, rs2
    """
    opcode = 0b0110011
    funct3 = 0b000
    funct7 = 0b0000000
    instr = f"{funct7:07b}{rs2:05b}{rs1:05b}{funct3:03b}{rd:05b}{opcode:07b}"
    instr = f"{int(instr,2):08x}"

    if newline:
        instr += "\n"
    return instr

def jump(imm):
    """
    JUMP imm
    """
    opcode = 0b1101111

    imm_field = imm & 0b11111111000000000000
    imm_field = imm_field | ((imm & 0b100000000000) << 8)
    imm_field = imm_field | ((imm & 0b11111111110) << 9)
    imm_field = imm_field | ((imm & 0b100000000000000000000) << 19)

    instr = (0b00000 << 7) | opcode
    instr = (imm_field << 12) | instr

    return instr



def load(rd, imm, rs1, size):
    """
    LOAD rd, imm(rs1)
    """
    opcode = 0b0000011

    sizes = {
        "B": 0b000,
        "W": 0b010,
    }

    funct3 = sizes[size]  # store word

    instr = (rd << 7) | opcode
    instr = (funct3 << 12) | instr
    instr = (rs1 << 15) | instr  # rs1
    instr = (imm << 20) | instr  # rs2

    return instr


def store(rs2, imm, rs1, size):
    """
    STORE rs2, imm(rs1)
    """
    opcode = 0b0100011
    lower_offset = imm & 0b11111
    upper_offset = imm & 0b111111100000

    sizes = {
        "B": 0b000,
        "W": 0b010,
    }

    funct3 = sizes[size]  # store word

    instr = (lower_offset << 7) | opcode
    instr = (funct3 << 12) | instr
    instr = (rs1 << 15) | instr  # rs1
    instr = (rs2 << 20) | instr  # rs2
    instr = (upper_offset << 25) | instr

    return instr
