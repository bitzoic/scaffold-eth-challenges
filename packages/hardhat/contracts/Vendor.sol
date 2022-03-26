pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  function buyTokens() public payable
  {
    uint256 amount = (tokensPerEth * msg.value) / 1 ether;
    yourToken.transfer(msg.sender, amount);
    emit BuyTokens(msg.sender, msg.value, amount);
  }

  // If someone send the contract eth just send back tokens
  receive() external payable {
    buyTokens();
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() external onlyOwner {
    (bool sent, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(sent, "Failed to send");
  }

  // ToDo: create a sellTokens() function:
  function sellTokens() external
  {

  }
}
