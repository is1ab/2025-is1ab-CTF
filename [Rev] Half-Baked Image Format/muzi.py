from PIL import Image
import numpy as np
import crc8

def main():
    inp = input("""
                Welcome to the is1ab Image Program
                It can convert images to MUZIs
                It will also display MUZIs

                [1] Convert Image to MUZI
                [2] Display MUZI

                """)
    match inp:
        case "1":
            start_conv()
        #case "2":
            #display() #TODO: Add
            '''
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣀⣀⣀⣀⣀⣀⣀⣀⣀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣀⡀⠂⠁⠁⠁⠁⠂⠂⠂⠂⠁⠁⠁⠁⠁⠁⠂⠄⡀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣀⠂⠁⠁⠂⡀⣀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣀⡀⠄⠂⠁ ⠁⠂⡀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣀⡀⠁⠂⡀⣀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣀⠄⠁  ⠁⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⡀⠁⠂⣀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⡀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣀⡀⠄⠄⠄⠄⠄⠄⠄⠄⡀⡀⣀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠂⠂⠄⠄⠄⡀⡀⠄⠄⠄⠄⠂⠂⠁⠁⠁⠂⠄⣀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠄⠄⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠄⠂⠁⠁⠄⣀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣀⠄ ⠁⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠂⠂⠂⠂⠂⠂⠂⠄⡀⣀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠁⠂⡀⡀⡀⡀⡀⡀⠄⠄⠁  ⠂⣀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠄⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠁ ⠄⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠁⠄⡀⣀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣀⠄⠂⠁⠁⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
            '''
        case _:
            return 0
    return 0

def start_conv():
    file = input("Enter the path to your image you want converted to a MUZI file:\n")
    out = input("Enter the path you’d like to write the MUZI to:\n")
    img = Image.open(file)
    w, h = img.size

    write = [
        b'\x4D', b'\x55', b'\x5A', b'\x49', b'\x00', b'\x01', b'\x00', b'\x02'
    ]

    for x in w.to_bytes(4):
        write.append(x.to_bytes(1))
    for y in h.to_bytes(4):
        write.append(y.to_bytes(1))

    write.append(b'\x57')
    write.append(b'\x49')
    write.append(b'\x46')
    write.append(b'\x49')
    
    for i in range(h):
        dat = [b'\x44',b'\x41',b'\x54',b'\x52']
        for j in range(w):
            dat.append(img.getpixel((j,i))[0].to_bytes(1)) 
        dat.append(getCheck(dat[4:]))
        for wa in dat:
            write.append(wa)

    for i in range(h): 
        dat = [b'\x44',b'\x41',b'\x54',b'\x47']
        for j in range(w):
            dat.append(img.getpixel((j,i))[1].to_bytes(1)) 
        dat.append(getCheck(dat[4:]))
        for wa in dat:
            write.append(wa)

    for i in range(h): 
        dat = [b'\x44',b'\x41',b'\x54',b'\x42'  ]
        for j in range(w):
            dat.append(img.getpixel((j,i))[2].to_bytes(1))
        dat.append(getCheck(dat[4:]))
        for wa in dat:
            write.append(wa)

    write.append(b'\x44')
    write.append(b'\x41')
    write.append(b'\x54')
    write.append(b'\x45')

    with open(out, "ab") as f:
        for b in write:
            f.write(b)

    return 0

def getCheck(datr):
    dat = ''
    for w in datr:
        dat+=chr(int.from_bytes(w))
    #print(datr)
    #print(dat.encode())
    return int.to_bytes(int(crc8.crc8(dat.encode()).hexdigest(),base=16),1)

if __name__ == '__main__':
    main()
