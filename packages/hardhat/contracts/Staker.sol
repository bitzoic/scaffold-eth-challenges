// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  event Stake(address, uint256);

  mapping(address => uint) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 30 seconds;
  bool public openForWithdrawl = false;

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
function stake() public payable {
  require(msg.value > 0, "Cannot stake 0 ether!");

  balances[msg.sender] += msg.value;
  emit Stake(msg.sender, msg.value);
} 

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() external {
    require(block.timestamp >= deadline, 0);
    require(address(this).balance >= threshold, openForWithdrawl = true);
    exampleExternalContract.complete{value: address(this).balance}();
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw() external {
    require(openForWithdrawl, "You cannot withdraw your stake");
    //withdraw(msg.sender);
  }



  // Add a `withdraw(address payable)` function lets users withdraw their balance
  function withdraw(address payable) internal {
    // require(balances[payable] > 0, "You do not have any ether to withdraw");

  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() external view returns (uint) {
    return deadline - block.timestamp;
  } 


  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }
}
