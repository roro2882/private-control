import base64
import time
import string
import random
def encode(key, clear):
    enc = []
    for i in range(len(clear)):
        key_c = key[i % len(key)]
        enc_c = chr((ord(clear[i]) + ord(key_c)) % 256)
        enc.append(enc_c)
    return base64.urlsafe_b64encode("".join(enc).encode()).decode()

def decode(key, enc):
    dec = []
    enc = base64.urlsafe_b64decode(enc).decode()
    for i in range(len(enc)):
        key_c = key[i % len(key)]
        dec_c = chr((256 + ord(enc[i]) - ord(key_c)) % 256)
        dec.append(dec_c)
    return "".join(dec)
def randStr(chars = string.ascii_uppercase + string.digits, N=10):
	return ''.join(random.choice(chars) for _ in range(N))
password = "simplepassword"
chars = string.digits+string.ascii_letters
N = 5
key = randStr(chars = chars, N=N)
result = encode(password,key)
print(result, key)
ctime =  time.time()

def test(nmax):
    n=0
    for i1 in chars:
        for i2 in chars:
            for i3 in chars:
                for i4 in chars:
                    for i5 in chars:
                        n+=1
                        testKey = i1+i2+i3+i4+i5
                        testresult = encode(password,testKey)
                        if testresult == result:
                            print('found key ! '+testKey)
                            return testKey
                        if n>nmax:
                            return
nmax=100000
test(nmax)
avgtime = (time.time()-ctime)/nmax
print('time',time.time()-ctime)
comb = len(chars)**N
print('time needed to crack the password(minutes):',comb*avgtime/(2*60))    
