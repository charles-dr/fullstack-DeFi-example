// stakeTokens
// unstakeTokens
// issueTokens
// addAllowedTokens
// getEthValue


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract TokenFarm is Ownable {

  address[] public allowedTokens;
  address[] public stakers;
  mapping(address => mapping(address => uint256)) public stakingBalance;
  mapping(address => uint256) public uniqueTokensStaked;
  mapping(address => address) public tokenPriceFeedMapping;
  IERC20 public dappToken;

  constructor(address _dappTokenAddress) {
    dappToken = IERC20(_dappTokenAddress);
  }

  function setPriceFeedContract(address _token, address _priceFeed) 
  public
  onlyOwner {
    tokenPriceFeedMapping[_token] = _priceFeed;
  }

  function issueTokens() public onlyOwner {
    for (
      uint256 stakersIndex = 0;
      stakersIndex < stakers.length;
      stakersIndex++
    ) {
      address recipient = stakers[stakersIndex];
      // send them a token reward based on their total value staked
      uint256 userTotalValue = getUserTotalValue(recipient);
      
      dappToken.transfer(recipient, userTotalValue);
    }
  }

  function getUserTotalValue(address _user) public view returns (uint256) {
    uint256 totalValue = 0;
    require(uniqueTokensStaked[_user] > 0, "No tokens staked!");
    for (
      uint256 allowedTokensIndex = 0;
      allowedTokensIndex < allowedTokens.length;
      allowedTokensIndex ++
    ) {
      totalValue = totalValue + getUserSingleTokenValue(_user, allowedTokens[allowedTokensIndex]);
    }
    return totalValue;
  }

  function getUserSingleTokenValue(address _user, address _token) public view returns (uint256) {
    // 1 ETH -> $2000
    // 200 DAI -> $200
    if (uniqueTokensStaked[_user] <= 0) {
      return 0;
    }
    // price of the token * stakingBalane[_token][_user]
    (uint256 price, uint256 decimals) = getTokenValue(_token);
    return (stakingBalance[_token][_user] * price / (10 ** decimals));
  }

  function getTokenValue(address _token) public view returns (uint256, uint256) {
    // priceFeedAddress
    address priceFeedAddress = tokenPriceFeedMapping[_token];
    AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddress);
    (, int256 price,,,) = priceFeed.latestRoundData();
    uint256 decimals = uint256(priceFeed.decimals());
    return (uint256(price), decimals);
  }

  function stakeToken(uint256 _amount, address _token) public {
    require(_amount > 0, "Amount must be more than 0");
    require(tokenIsAllowed(_token), "Token is currently not allowed");
    IERC20(_token).transferFrom(msg.sender, address(this), _amount);
    updateUniqueTokensStaked(msg.sender, _token);
    stakingBalance[_token][msg.sender] = stakingBalance[_token][msg.sender] + _amount;
    if (uniqueTokensStaked[msg.sender] == 1) {
      stakers.push(msg.sender);
    }
  }

  function unstakeToken(address _token) public {
    uint256 balance = stakingBalance[_token][msg.sender];
    require(balance > 0, "Staking balance can not be zero!");
    IERC20(_token).transfer(msg.sender, balance);
    stakingBalance[_token][msg.sender] = 0;
    uniqueTokensStaked[msg.sender] = uniqueTokensStaked[msg.sender] - 1;
    
  }

  function updateUniqueTokensStaked(address _user, address _token) internal {
    if (stakingBalance[_token][_user] <= 0) {
      uniqueTokensStaked[_user] = uniqueTokensStaked[_user] + 1;
    }
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