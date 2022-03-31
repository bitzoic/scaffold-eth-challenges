pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

contract MetaMultiSigWallet {

    mapping(address => bool) public signers;
    uint256 public signersRequired;
    uint256 public totalSigners;

    constructor () {
        
    }

    modifier onlySelf 
    {
        require(msg.sender == address(this));
        _;
    }

    modifier onlySigner
    {
        require(signers[msg.sender] == true);
        _;
    }

    function executeTransaction(bytes memory signatures) external {

    }

    function recover(bytes memory signatures) internal returns (bytes memory)
    {   

    }

    function generateSignature(bytes32 parameters) public view onlySigner returns (bytes32)
    {

    }

    function addSigner(address newSigner) public onlySelf
    {
        require(signers[newSigner] == false, "You cannot add the same signers twice!");

        totalSigners = totalSigners + 1;
        signers[newSigner] = true;
    }

    function removeSigner(address oldSigner) public onlySelf
    {
        require(totalSigners > 2, "There cannot be only 1 signer!");
        require(signersRequired <= totalSigners - 1, "You need to reduce the required signers to remove another");

        totalSigners = totalSigners - 1;
        signers[oldSigner] = false;
    }


    function transferFunds(address to) public onlySelf
    {

    }

    function updateSignaturesRequired(uint256 required) public onlySelf
    {
        require(totalSigners <= required, "You cannot require more signers than there are available");
        signersRequired = required;
    }
}