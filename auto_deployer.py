#!/usr/bin/env python3

from web3 import Web3, HTTPProvider
import os
import json
from sh import solc
import json
import ast
from ethereum.utils import mk_contract_address, sha3, normalize_address, encode_hex


C = {'INFURA_MAIN': os.environ['MAINNET'],
        'TEST': 'http://127.0.0.1:8545', 
        'L_MAIN': 'http://192.168.1.18:9545',
        'REMOTE_MAIN': 'http://138.68.10.233:54671',
        'L_ROPSTEN':'http://192.168.1.19:9545'}

def addr_port(var):
    s = var.split(':')
    addr = s[0]+':'+s[1]
    port = s[-1]
    return addr, port

# Returns a tupple of all the inputs
def build_command(inputs):

    for mem in inputs:
        if type(mem) == type(list):
            print ()
    
            c_list.append()
            
        if type(mem) == type('s'):
            print ()

    return c_list

def linker (library_addr):


    #solc --optimize --bin MetaCoin.sol | solc --link --libraries TestLib:<address>
    #
    solc("--libraries", "SafeMath:", library_addr)
    pass


def read_byte_code(contract_path):
   
    with open(contract_path, 'r') as c:
        return c.readline()

def read_abi(contract_path):

    s = ''
    with open(contract_path) as c:
        for line in c:
            s = s + line
   
    return(json.loads(s))

def determine_addresses(deployer, contrac_quanty):

    addresses = [] 

    for i in range(contrac_quanty):

        _addr = str(encode_hex(mk_contract_address(deployer, i)))
        
        # Removes the extra b from the front
        _addr = "0x" + addr[1:]

        addresses.append(_addr)

    safe = addresses[0]
    crow = addresses[1]
    pre = addresses[2]
    token = addresses[3]

    return safe, crow, pre, token

if __name__=='__main__':


    # THis just checks the status of the other networks
    for k in C:
        w3 = Web3(HTTPProvider(C[k]))
        print ('{}: {}'.format(k, C[k]))
        print (w3.eth.blockNumber)


    w3 = Web3(HTTPProvider(C['TEST']))

    temp = w3.eth.accounts
    # MAKE SURE THAT THE ACCOUNT IS UNLOCKED AT THE NODE
    deployer = temp[-1]

    pk = '23ec593c45028968639e12ed8857dd4ccadb92888108caeb9bdeb2f200263837' 
    #w3.personal.unlockAccount(deployer, pk)

    c_path = 'build/SafeMath.'
    safeMath = w3.eth.contract()
    safeMath.bytecode = read_byte_code(c_path + 'bin')
    safeMath.abi = read_abi(c_path + 'abi')
    safeMath.deploy()
   



