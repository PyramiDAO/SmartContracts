// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
* @title StrategyStandard
* @author Caron Case (carsonpcase@gmail.com)
    contract to standardize what strategies do 
*/
abstract contract StrategyStandard is Ownable{
    address public immutable treasury;

    uint256 underlyingInvested;
    uint256 underlyingExposedToSwaps;

    constructor(address _treasury){
        treasury = _treasury;
    }

    /**
    * @dev fund function to provide funds to the strategy
    * override to provide with the actual logic of the investment strategy
     */
    function fund(uint256 _amountInvestment) external virtual onlyOwner{
        underlyingInvested += _amountInvestment;
    }

    /**
    * @dev function for owner (treasury) to remove funds 
     */
    function removeFunds(uint256 _amountToRemove) external virtual onlyOwner{
        require(underlyingInvested > underlyingExposedToSwaps + _amountToRemove, "There's not enough free assets in this strategy to remove this amount"); 
    }

    /**
    * @dev function to buy swap on the strategy. Can only be done if it's free
     */
    function buySwap(uint256 _amountUnderlying) external virtual{
        require(underlyingInvested > underlyingExposedToSwaps + _amountUnderlying, "There's not enough free assets in this strategy to invest this amount"); 
        underlyingExposedToSwaps += _amountUnderlying;
        _issueSwap(msg.sender);
    }

    /**
    * @dev handles logic of issuing swap
     */
    function _issueSwap(address _issueTo) internal{
        // issue NFT with supperfuild superapp
        // and send other end of NFT to treasury
    }
}