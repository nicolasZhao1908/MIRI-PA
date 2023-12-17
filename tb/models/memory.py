class Memory:
    def __init__(self, fill_data_width=128, spaces=128 * 4, cell_width=8):
        self.fill_data_width = fill_data_width
        self.size = spaces
        self.mem = [0] * spaces
        self.cell_width = cell_width
        self.cells_per_line = fill_data_width // cell_width
        self.cells_per_word = 32 // cell_width

    def store(self, addr, data, word):
        if (not word):
            self.mem[addr] = data
        else:
            for i in range(0, self.cells_per_word):
                mask = 0xFF << (8 * i)
                local_data = (data & mask) >> (8 * i)
                self.mem[addr + i] = local_data

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
