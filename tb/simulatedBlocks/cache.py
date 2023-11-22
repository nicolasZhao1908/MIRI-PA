
class Cache:
    def __init__(self, set_bits):
        self.set_bits = set_bits
        self.lines = [[0, 0, 0] for _ in range(2 ** set_bits)]
        self.set_mask = ((0b1 << set_bits) - 1)

    def put(self, inp, data, valid = True):
        set = inp & self.set_mask
        self.lines[set][0] = valid
        self.lines[set][1] = inp
        self.lines[set][2] = data

    def read(self, inp):
        set = inp & self.set_mask
        hit = self.lines[set][0] and self.lines[set][1] == inp
        return hit, self.lines[set][2]


# class CachedMemoryModel:
#
#     def __init__(self, set_bits = 2):
#         self.cache = Cache(set_bits)
#         self.mem = Memory()
#
#     def put(self, inp, data):
#         self.mem.store(inp, data)
#         #TODO Fehlerhafte implementation aber im moment ist der Cache auch so aufgebaut!
#         self.cache.put(inp, data, False)
#
#     def read(self, inp):
#         hit, data = self.cache.read(inp)
#         if not hit:
#             self.cache.put(inp, self.mem.load(inp), True)
#
#             hit, data = self.cache.read(inp)
#             assert hit, "Hit is guaranteed"
#
#         return data


