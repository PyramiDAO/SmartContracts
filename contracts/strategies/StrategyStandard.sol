// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITreasury{
    function stableCoin() external returns(IERC20);
}

/**
* @title StrategyStandard
* @author Caron Case (carsonpcase@gmail.com)
    contract to standardize what strategies do 
*/
abstract contract StrategyStandard is Ownable{
    address public immutable treasury;
    address internal immutable stableCoin;
    uint256 underlyingInvested;
    uint256 underlyingExposedToSwaps;

    constructor(address _treasury) Ownable(){
        treasury = _treasury;
        stableCoin = address(ITreasury(_treasury).stableCoin());
    }

    /**
    * @dev fund function to provide funds to the strategy
    * override to provide with the actual logic of the investment strategy
     */
    function fund(uint256 _amountInvestment) public virtual onlyOwner{
        underlyingInvested += _amountInvestment;
        IERC20(stableCoin).transferFrom(treasury, address(this), _amountInvestment);
    }   

    /**
    * @dev function for owner (treasury) to remove funds 
     */
    function removeFunds(uint256 _amountToRemove) public virtual onlyOwner{
        require(underlyingInvested > underlyingExposedToSwaps + _amountToRemove, "There's not enough free assets in this strategy to remove this amount"); 
    }

    /**
    * @dev function to buy swap on the strategy. Can only be done if it's free
     */
    function buySwap(uint256 _amountUnderlying) public virtual{
        require(underlyingInvested > underlyingExposedToSwaps + _amountUnderlying, "There's not enough free assets in this strategy to invest this amount"); 
        underlyingExposedToSwaps += _amountUnderlying;
        _issueSwap(msg.sender, _amountUnderlying);
    }

    /**
    * @dev handles logic of issuing swap
     */
    function _issueSwap(address _issueTo, uint _amountUnderlying) internal{
        // issue NFT with supperfuild superapp
        // and send other end of NFT to treasury
    }
}