// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ISwapReceiver.sol";

/**
* @title Treasury
* @author Caron Case (carsonpcase@gmail.com)
    Treasury is to be governed by the governance time lock and thus that is the owner
 */
contract Treasury is Ownable, ISwapReceiver {
    IERC20 public stablecoin;
    IERC20 public nativeToken;

    mapping(address => uint256) public strategiesApprovedBalances;

    constructor(address _stableCoin, address _nativeToken) Ownable(){
        stablecoin = IERC20(_stableCoin);
        nativeToken = IERC20(_nativeToken);
    }

    function transferFundsToStrategy(address _strategy, uint _amount) external onlyOwner{
        stablecoin.transfer(_strategy,_amount);
        strategiesApprovedBalances[_strategy] = 2^256-1;        // give strategies full access for now
    }

    function verifyNewSwap(address _swapCreator, uint _amountUnderlying) external view override returns(bool){
        return(strategiesApprovedBalances[_swapCreator] >= _amountUnderlying);
    }
}
