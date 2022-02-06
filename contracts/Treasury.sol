// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ISwapReceiver.sol";
import "./interfaces/IStrategy.sol";

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

    event NewSettlement(int amount);

    function transferFundsToStrategy(address _strategy, uint _amount) external onlyOwner{
        stablecoin.approve(_strategy,_amount);
        IStrategy(_strategy).fund(_amount);
        strategiesApprovedBalances[_strategy] = 2**256-1;        // give strategies full access for now
    }

    function verifyNewSwap(address _swapCreator, uint _amountUnderlying) external view override returns(bool){
        return(strategiesApprovedBalances[_swapCreator] >= _amountUnderlying);
    }

    function settle(int _usdSettlement, address _recipient) override external{
        require(strategiesApprovedBalances[msg.sender] >= 0,"Only a valid strategy can call this");
        /// todo request funds from strategy to settle with instead of internal balances
        if(_usdSettlement == 0){return;}
        if(_usdSettlement > 0){
            stablecoin.transfer(_recipient, uint(_usdSettlement));
        }else{
            /// todo collateral
        }
        emit NewSettlement(_usdSettlement);
    }

}
