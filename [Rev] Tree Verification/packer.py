import argparse
import lief
import os
import subprocess

def align(x, al):
    """ return <x> aligned to <al> """
    if x % al == 0:
        return x
    else:
        return x - (x % al) + al

def pad_data(data, al):
    """ return <data> padded with 0 to a size aligned with <al> """
    return data + ([0] * (align(len(data), al) - len(data)))

def compile_stub(input_cfile, output_exe_file, more_parameters = []):
    cmd = (["gcc.exe", "-m32", input_cfile, "-o", output_exe_file] # Force the ImageBase of the destination PE
        + more_parameters +
        ["-Wl,--entry=__start", # define the entry point
        "-nostartfiles", "-nostdlib", # no standard lib
        "-fno-ident", "-fno-asynchronous-unwind-tables", # Remove unnecessary sections
        "-lkernel32" # Add necessary imports
        ])
    print("[+] Compiling stub : " + " ".join(cmd))
    subprocess.run(cmd)
    subprocess.run(["strip.exe", output_exe_file])

def pack_data(data):
    secret_key = b"dLkptn2}$bjVN6k)w{'GRX58u(P@61zh"
    key_len = len(secret_key)
    result = []
    for i, byte in enumerate(data):
        key_byte = secret_key[i % key_len]
        dynamic_val = i & 0xFF
        obfuscated_byte = ((byte + dynamic_val) & 0xFF) ^ key_byte
        result.append(obfuscated_byte)
    return result

def pack(input_PE_name, output_PE_name, unpack_stub_source_name, pack_data_fun):
    input_PE = lief.PE.parse(input_PE_name)
    unpack_stub_output_name = unpack_stub_source_name.replace(".c", ".exe")
    compile_stub(unpack_stub_source_name,  unpack_stub_output_name, more_parameters=[])
    unpack_PE = lief.PE.parse(unpack_stub_output_name)
    os.remove(unpack_stub_output_name)
    
    file_alignment = unpack_PE.optional_header.file_alignment
    section_alignment = unpack_PE.optional_header.section_alignment
    
    ASLR = (input_PE.optional_header.dll_characteristics & lief.PE.OptionalHeader.DLL_CHARACTERISTICS.DYNAMIC_BASE != 0)
    if ASLR:
        output_PE = unpack_PE
    else:
        min_RVA = min([x.virtual_address for x in input_PE.sections])
        max_RVA = max([x.virtual_address + x.size for x in input_PE.sections])
        
        alloc_section = lief.PE.Section(".alloc")
        alloc_section.virtual_address = min_RVA
        alloc_section.virtual_size = align(max_RVA - min_RVA, section_alignment)
        alloc_section.characteristics = (lief.PE.Section.CHARACTERISTICS.MEM_READ
                                        | lief.PE.Section.CHARACTERISTICS.MEM_WRITE
                                        | lief.PE.Section.CHARACTERISTICS.CNT_UNINITIALIZED_DATA)
        
        min_unpack_RVA = min([x.virtual_address for x in unpack_PE.sections])
        shift_RVA = (min_RVA + alloc_section.virtual_size) - min_unpack_RVA
        
        compile_parameters = [f"-Wl,--image-base={hex(input_PE.optional_header.imagebase)}"]
        for s in unpack_PE.sections:
            compile_parameters += [f"-Wl,--section-start={s.name}={hex(input_PE.optional_header.imagebase + s.virtual_address + shift_RVA )}"]
        
        shifted_unpack_stub_output_name = "shifted_" + unpack_stub_source_name.replace(".c", ".exe")
        compile_stub(unpack_stub_source_name, shifted_unpack_stub_output_name, compile_parameters)
        unpack_shifted_PE = lief.PE.parse(shifted_unpack_stub_output_name)
        os.remove(shifted_unpack_stub_output_name)
        
        output_PE = lief.PE.Binary("pe_from_scratch", lief.PE.PE_TYPE.PE32)
        output_PE.optional_header.imagebase = unpack_shifted_PE.optional_header.imagebase
        output_PE.optional_header.addressof_entrypoint = unpack_shifted_PE.optional_header.addressof_entrypoint
        output_PE.optional_header.section_alignment = unpack_shifted_PE.optional_header.section_alignment
        output_PE.optional_header.file_alignment = unpack_shifted_PE.optional_header.file_alignment
        output_PE.optional_header.sizeof_image = unpack_shifted_PE.optional_header.sizeof_image
        
        output_PE.optional_header.dll_characteristics = 0
        for i in range(0, 15):
            output_PE.data_directories[i].rva = unpack_shifted_PE.data_directories[i].rva
            output_PE.data_directories[i].size = unpack_shifted_PE.data_directories[i].size    
        
        output_PE.add_section(alloc_section)
        for s in unpack_shifted_PE.sections:
            output_PE.add_section(s)
    
    with open(input_PE_name, "rb") as f:
        input_PE_data = f.read()
    
    packed_data = pack_data_fun(list(input_PE_data))
    packed_data = pad_data(packed_data, file_alignment)

    packed_section = lief.PE.Section(".is1ab")
    packed_section.content = packed_data
    packed_section.size = len(packed_data)
    packed_section.characteristics = (lief.PE.Section.CHARACTERISTICS.MEM_READ
                                      | lief.PE.Section.CHARACTERISTICS.MEM_WRITE
                                      | lief.PE.Section.CHARACTERISTICS.CNT_INITIALIZED_DATA)
    output_PE.add_section(packed_section)
    output_PE.optional_header.sizeof_image = 0
    if(os.path.exists(output_PE_name)):
        os.remove(output_PE_name)
    
    builder = lief.PE.Builder(output_PE)
    builder.build()
    builder.write(output_PE_name)

if __name__ =="__main__" :
    parser = argparse.ArgumentParser(description='Pack PE binary')
    parser.add_argument('input', metavar="FILE", help='input file')
    parser.add_argument('-o', metavar="FILE", help='output', default="packed.exe")
    args = parser.parse_args()
    
    pack(args.input, args.o, "unpack_stub.c", pack_data)
    