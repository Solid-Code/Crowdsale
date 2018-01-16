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

def linker (library_addr, library_name):


    #solc --optimize --bin MetaCoin.sol | solc --link --libraries TestLib:<address>
    #
    solc("--libraries", library_name, library_addr)
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

def determine_addresses(deployer, tx_count, qty):

    addresses = []
    for i in range(tx_count, tx_count + qty):

        _addr = str(encode_hex(mk_contract_address(deployer, i)))
        
        addresses.append(_addr)

    return addresses

# Generates all the contracts classes needed
def read_all_contracts(source_path):

    path = os.path.abspath(source_path)
    
    file_list = os.listdir(source_path)
    only_names_list = []


    for f in file_list:
        only_names_list.append(f.split('.')[0])

    names_list = list(set(only_names_list))
    contract_list = {}

    for n in names_list:
        n = path + '/' + n
        abi = read_abi(n + '.abi')
        byte = read_byte_code(n + '.bin')
        name = n.split('/')[-1]

        c = w3.eth.contract(abi=abi, bytecode=byte, contract_name=name)
        
        contract_list[name] = {'class': c}

    return contract_list

def read_deploy_args(contracts):

    ####### This needs to go in a toml file. And a generator function
    contracts['Presale']['args']=[
                    "0x73f6875f53db77141b4df3bfbb4d76a162a195f0",
                    200,
                    1000,
                    0,
                    1,
                    contracts['Token']['addr'],
                    ]

    contracts['Crowdsale']['args' ]= ["0x73f6875f53db77141b4df3bfbb4d76a162a195f0",
                        10,
                        1000,
                        0,
                        3,
                        contracts['Token']['addr'],
                        100,
                        10000,
                        [20,10,0],
                        [1,1,1],
                        10
                        ]



    contracts['Token']['args'] = [
                        contracts['Presale']['addr'], 
                        contracts['Presale']['addr']
                        ]


    contracts['SafeMath']['args'] = ''
    return contracts

    

if __name__=='__main__':


    w3 = Web3(HTTPProvider(C['TEST']))
    deployer = w3.eth.accounts[-1]
    print (deployer)
    print ()
    
    tx_count = w3.eth.getTransactionCount(deployer)
    contracts = read_all_contracts('build')
    contrs_addrs = determine_addresses(deployer, tx_count, len(contracts))

    # Assign address to tokens
    for i, c_key in enumerate(contracts):
        contracts[c_key]['addr'] = contrs_addrs[i]

   
    contracts = read_deploy_args(contracts)

    """
    for c_key in contracts:
        print (contracts[c_key])
        print()
    """


    for c_key in contracts:

        contracts[c_key]['class'].deploy(
                {'from': deployer}, args = contracts[c_key]['args']
                )



