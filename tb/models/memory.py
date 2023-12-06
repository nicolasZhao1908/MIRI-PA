class Memory:
    def __init__(self, fill_data_width=128, spaces=128, cell_width=32):
        self.fill_data_width = fill_data_width
        self.size = spaces
        self.mem = [0] * spaces
        self.cell_width = cell_width
        self.cells_per_line = fill_data_width // cell_width

    def store(self, addr, data):
        self.mem[addr] = data

    def load(self, addr):
        line_start = (addr // self.cells_per_line) * self.cells_per_line

        result = []
        for i in range(self.cells_per_line):
            result.append(self.mem[line_start + i])
        return result


    def load_ONLY_ONE(self, addr):
        return self.mem[addr]

    def load_bin_str(self, addr):
        arr = self.load(addr)
        res = ""
        formatS = f":0{self.cell_width}b"
        formatS = "{" + formatS + "}"
        for i in range(self.cells_per_line):
            binS = formatS.format(arr[i])
            res = f"{binS}{res}"

        return res
