pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MetaMultiSigWallet {

    using ECDSA for bytes32;    

    mapping(address => bool) public signers;
    uint256 public signersRequired;
    uint256 public totalSigners;
    int256 public nonce;

    constructor (address[] memory _signers, uint256 _requiredSigners) {
        require(_requiredSigners > 0, "Required Signers must be greater than 0");
        require(_signers.length >= _requiredSigners, "Cannot require more signers than available");

        for (uint i =0; i < _signers.length; i++)
        {
            address newSigner = _signers[i];
            require(newSigner != address(0), "A signer's address was null!");
            require(signers[newSigner] == false, "Tried to add the same signer twice");
            signers[_signers[i]] = true;
            totalSigners = totalSigners + 1;
        }
        signersRequired = _requiredSigners;
    }

    modifier onlySelf 
    {
        require(msg.sender == address(this));
        _;
    }

    modifier onlySigner
    {
        require(signers[msg.sender] == true, "Sender is not a signer");
        _;
    }

    function executeTransaction(address payable _to, bytes memory _data, uint256 _value, bytes[] memory _signatures) public onlySigner 
    {   
        // Hash for the transaction that the signers must approve
        bytes32 _hash = generateHash(nonce, _to, value, _data);
        nonce++;

        uint256 approved = 0;
        address lastAddress;

        // Check the signatures
        for (uint i = 0; i < _signatures.length; i++)
        {
            address recovered = recover(_hash, _signatures[i]);
            require(recovered > lastAddress, "Non-valid signature or signatures are out of order");
            lastAddress = recovered;

            if (signers[recovered]) {
                approved = approved + 1;
            }
            else
            {
                require(false, "Invalid signer given");
            }
        }

        require(approved >= signersRequired, "Not enough signers");
        (bool sent, ) = to.call{value: value}(data);
        require(sent, "Failed transaction");
    }

    function recover(bytes32 _data, bytes memory _signature) public view returns (address)
    {       
        return _data.toEthSignedMessageHash().recover(_signature);
    }

    function generateHash(uint256 _nonce, address _to, uint256 _value, bytes memory _data) public view returns (bytes32)
    {
        return keccak25(abi.encodePacked(_nonce, _to, _value, _data));
    }

    function addSigner(address _newSigner) public onlySelf
    {
        require(signers[_newSigner] == false, "You cannot add the same signers twice!");
        require(_newSigner != address(0), "Null addrress cannot be a signer!");

        totalSigners = totalSigners + 1;
        signers[_newSigner] = true;
    }

    function removeSigner(address _oldSigner) public onlySelf
    {
        require(totalSigners > 2, "There cannot be only 1 signer! It's a 'multi'sig");
        require(signersRequired <= totalSigners - 1, "You need to reduce the required signers to remove another");

        totalSigners = totalSigners - 1;
        signers[_oldSigner] = false;
    }

    function updateSignaturesRequired(uint256 required) public onlySelf
    {
        require(totalSigners <= required, "You cannot require more signers than there are available");
        require(totalSigners > 0, "You cannot set the required signatures to 0");
        signersRequired = required;
    }

    receive() payable external {

    }
}