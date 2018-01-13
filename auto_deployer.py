#!/usr/bin/env python3

from web3 import Web3, HTTPProvider
import os
import json
from sh import solc
import json
import ast
from ethereum.utils import mk_contract_address, sha3, normalize_address, encode_hex


C = {'ROPSTEN': os.environ['ROPSTEN'], 'MAIN': os.environ['MAINNET'] ,'TEST': 'HTTP://127.0.0.1:8545'}

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

    with open(contract_path) as c:
        return(json.loads(c.readlines()))

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


    w3 = Web3(HTTPProvider(C['TEST']))

    temp = w3.eth.accounts
    # MAKE SURE THAT THE ACCOUNT IS UNLOCKED AT THE NODE
    deployer = temp[-1]

    pk = 'c3581345eb58d233d96f36b7456e4d3c6ae935b9e2c98805ffd6a280d6c1b97d' 
    #w3.personal.unlockAccount(deployer, pk)

    safeMath = w3.eth.contract()

    safeMath.bytecode = read_byte_code('build/SafeMath.bin')
    print (safeMath.bytecode)
    safeMath.deploy()
    
