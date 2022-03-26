pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  function buyTokens() public payable
  {
    require(msg.value > 0, "Cannot buy 0 tokens!");
    uint256 amount = (tokensPerEth * msg.value);
    require(amount < yourToken.balanceOf(address(this)), "Not enough tokens for sale");
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
  function sellTokens(uint256 tokens) external
  {
    yourToken.transferFrom(msg.sender, address(this), tokens);

    uint256 ethToTransfer = tokens / tokensPerEth;
    (bool sent, ) = payable(msg.sender).call{value: ethToTransfer}("");
    require(sent, "Failed to send");
    emit SellTokens(msg.sender, ethToTransfer, tokens);
  }
}
