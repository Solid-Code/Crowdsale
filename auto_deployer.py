#!/usr/bin/env python3

from web3 import Web3, HTTPProvider
import os
import json
from sh import solc
import json
import ast
from ethereum.utils import mk_contract_address, sha3, normalize_address, encode_hex


"""
https://mainnet.infura.io/PEEKRSA9G1J03LDyMfQ3 

Test Ethereum Network (Ropsten)

https://ropsten.infura.io/PEEKRSA9G1J03LDyMfQ3 

Test Ethereum Network (Rinkeby)

https://rinkeby.infura.io/PEEKRSA9G1J03LDyMfQ3 

Test Ethereum Network (Kovan)

https://kovan.infura.io/PEEKRSA9G1J03LDyMfQ3 

Test Ethereum Network (INFURAnet)

https://infuranet.infura.io/PEEKRSA9G1J03LDyMfQ3
"""


C = {
        #'INFURA_MAIN': 'https://mainnet.infura.io/PEEKRSA9G1J03LDyMfQ3',
        'TEST': 'http://127.0.0.1:8545', 
        #'L_MAIN': 'http://192.168.1.18:9545',
        'REMOTE_MAIN': 'http://138.68.10.233:54671',
        #'L_ROPSTEN':'http://192.168.1.19:9545'
        }

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

    for i in range(contrac_quanty):

        _addr = str(encode_hex(mk_contract_address(deployer, i)))
        
        # Removes the extra b from the front
        _addr = "0x" + addr[1:]

        addresses.append(_addr)

    return safe, crow, pre, token

# Generates all the contracts classes needed
def read_all_contracts(source_path):

    file_list = os.listdir(source_path)

    contract_list = []
    C = w3.eth.contract()
    for f in file_list:

        path = os.path.abspath(f)
        if 'abi' in f:
            C.abi = read_abi(path)

        if 'bin' in f:
            C.byte_code(read_byte_code(path)


        contract = w3.eth.contract()



if __name__=='__main__':


    # THis just checks the status of the other networks
    #for k in C:
    #    w3 = Web3(HTTPProvider(C[k]))
    #    print ('{}: {}'.format(k, C[k]))
    #    print (w3.eth.blockNumber)


    w3 = Web3(HTTPProvider(C['TEST']))
    deployer = w3.eth.accounts[-1]

    #print ('{}: {}'.format(deployer, w3.eth.getBalance(deployer)))
    
    # Sometimes needed (It is better to use a prompt) but you have to be careful
    # About encrypting the traffic because the Private K is in plain text
    #w3.personal.unlockAccount(deployer, '')

    c_path = 'build/SafeMath.'
    safeMath = w3.eth.contract()
    safeMath.bytecode = read_byte_code(c_path + 'bin')
    safeMath.abi = read_abi(c_path + 'abi')

    txan = w3.eth.sendTransaction({'from': w3.eth.coinbase , 'data': '0x' + safeMath.bytecode})

    safeMath.deploy({'from': w3.eth.coinbase})
