// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
* @title Treasury
* @author Caron Case (carsonpcase@gmail.com)
    Treasury is to be governed by the governance time lock and thus that is the owner
 */
contract Treasury is Ownable {
    IERC20 public stablecoin;
    IERC20 public nativeToken;

    constructor(address _stableCoin, address _nativeToken){
        stableCoin = _stableCoin;
        nativeToken = _nativeToken;
    }
