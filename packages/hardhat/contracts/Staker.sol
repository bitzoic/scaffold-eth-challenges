// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  event Stake(address, uint256);

  mapping(address => uint) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 72 hours;
  bool public openForWithdrawl = false;
  bool public executed = false;

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier notCompleted() {
    require(exampleExternalContract.completed() == false, "It hasn't been completed!");
    _;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable {
    require(msg.value > 0, "Cannot stake 0 ether!");
    require(timeLeft() != 0, "No longer accepting stake");

    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  } 

  function stakeAddress(address addy) public payable {
    require(msg.value > 0, "Cannot stake 0 ether!");
    require(timeLeft() != 0, "No longer accepting stake");

    balances[addy] += msg.value;
    emit Stake(addy, msg.value);
  } 

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() external notCompleted {
    require(!executed, "The decision has already been made!");
    require(block.timestamp >= deadline, "Deadline has not passed");
    if (address(this).balance < threshold)
    {
      openForWithdrawl = true;
    }
    else 
    {
      exampleExternalContract.complete{value: address(this).balance}();
    }
    executed = true;
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw() public notCompleted {
    withdrawPayment(msg.sender);
  }

  // Add a `withdraw(address payable)` function lets users withdraw their balance
  function withdrawPayment(address addy) public notCompleted {
    require(openForWithdrawl, "You cannot withdraw your stake yet");
    require(balances[addy] > 0, "You do not have any funds to withdraw");
    uint256 balance = balances[addy];
    balances[addy] = 0;
    (bool sent, ) = payable(addy).call{value: balance}("");
    require(sent, "Failed to send");
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint) {
    if (block.timestamp >= deadline)
    {
      return 0;
    }
    return deadline - block.timestamp;
  } 


  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }
}
