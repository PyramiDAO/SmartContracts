// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "./StrategyStandard.sol";
import "../interfaces/IUniswapV2Router02.sol";

/**
* @title ETHHODLStrategy
* @author Caron Case (carsonpcase@gmail.com)
    contract to standardize what strategies do 
*/
contract ETHHODLStrategy is StrategyStandard{
    IUniswapV2Router02 public immutable dex;

    constructor(address _treasury, address _dex) StrategyStandard(_treasury){
        dex = IUniswapV2Router02(_dex);
    }

    function fund(uint256 _amountInvestment) public override onlyOwner{
        super.fund(_amountInvestment);
        
        address[] memory path = new address[](2);
        path[0] = stableCoin;
        path[1] = dex.WETH();

        dex.swapExactTokensForETH(_amountInvestment,0,path,address(this),block.timestamp + 30);
    }

    function removeFunds(uint256 _amountToRemove) public override onlyOwner{
        super.removeFunds(_amountToRemove);

        address[] memory path = new address[](2);
        path[0] = dex.WETH();
        path[1] = stableCoin;

        dex.swapExactETHForTokens{value: _amountToRemove}(0, path, treasury, block.timestamp + 30);
    }

}