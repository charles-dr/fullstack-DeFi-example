// stakeTokens
// unstakeTokens
// issueTokens
// addAllowedTokens
// getEthValue


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenFarm is Ownable {

  address[] public allowedTokens;

  function stakeToken(uint256 _amount, address _token) public {
    require(_amount > 0, "Amount must be more than 0");
    require(tokenIsAllowed(_token), "Token is currently not allowed");
  }

  function addAllowedTokens(address _token) public onlyOwner {
    allowedTokens.push(_token);
  }

  function tokenIsAllowed(address _token) public view returns (bool) {
    for (uint256 allowedTokenIndex = 0; allowedTokenIndex < allowedTokens.length; allowedTokenIndex++) {
      if (allowedTokens[allowedTokenIndex] == _token) {
        return true;
      }
    }
    return false;
  }
}