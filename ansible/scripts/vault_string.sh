#!/bin/bash

cd $(dirname ${BASH_SOURCE})/..
pwd

# Define vars
decrypt=false
encrypt=false
vault_id=
input_file=""

# Usage info
usage() {
    echo "Usage: $0 [-e | -d] [-v vault_id] [-i input_file]"
    echo "  -e : Encrypt string to ansible vault"
    echo "  -d : Decrypt ansible vault to string"
    echo "  -v vault_id : Specify vault-id (default: product)"
    echo "  -i input_file : Specify input file containing the string to encrypt/decrypt"
    echo "  -h : Print this usage information"
}

# Define functions
decrypt_string() {
    if [[ -n "$input_file" ]]; then
        ansible-vault decrypt "$input_file"
    else
        ansible-vault decrypt
    fi
}

encrypt_string() {
    if [[ -n "$input_file" ]]; then
        ansible-vault encrypt_string --encrypt-vault-id "$vault_id" < "$input_file"
    else
        ansible-vault encrypt_string --encrypt-vault-id "$vault_id"
    fi
}

# Read parameters
while [ $# -gt 0 ]; do
    case $1 in
        -e) encrypt=true ;;
        -d) decrypt=true ;;
        -v) vault_id=$2; shift ;;
        -i) input_file=$2; shift ;;
        -h) usage; exit 0 ;;
        *) echo "ERROR: Unknown parameter $1"; usage; exit 1 ;;
    esac
    shift
done

# Check parameter usage
if [[ $decrypt == $encrypt ]]; then
    echo "ERROR: You must define -e (encrypt) OR -d (decrypt)"
    usage
    exit 1
fi

# Perform action
if $decrypt; then
    decrypt_string
else
    encrypt_string
fi