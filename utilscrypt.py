import sys,json,base64,os,getpass
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives import hashes
def key(pw,salt,it): return PBKDF2HMAC(algorithm=hashes.SHA256(),length=32,salt=salt,iterations=it).derive(pw.encode())
def dec(path,pw):
    o=json.load(open(path,encoding='utf-8')); b=base64.b64decode
    return AESGCM(key(pw,b(o['salt']),o['iter'])).decrypt(b(o['iv']),b(o['ct']),None).decode('utf-8')
def enc(text,pw,path):
    salt,iv=os.urandom(16),os.urandom(12); it=600000
    ct=AESGCM(key(pw,salt,it)).encrypt(iv,text.encode('utf-8'),None); e=base64.b64encode
    json.dump({'v':1,'alg':'AES-256-GCM','kdf':'PBKDF2-SHA256','iter':it,'salt':e(salt).decode(),'iv':e(iv).decode(),'ct':e(ct).decode()},open(path,'w',encoding='utf-8'),indent=1); open(path,'a').write('\n')
