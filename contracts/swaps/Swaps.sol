// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// initializing the CFA Library
import {
    IConstantFlowAgreementV1
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";

import {
    ISuperfluid,
    ISuperToken,
    ISuperApp,
    ISuperAgreement,
    ContextDefinitions,
    SuperAppDefinitions
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import "../interfaces/ISwapReceiver.sol";

contract Swaps is ERC721, Ownable{

    uint public index = 0;

    IConstantFlowAgreementV1 private _cfa; // the stored constant flow agreement class address

    address public token;
    mapping(address => int96) public payerRequiredFlowRates;        //Required payments for each payer

    struct asset{
        uint amountUnderlyingExposed;
        uint priceUSD;
        address oracle;
    }

    mapping(uint => asset) public receiverAssetsOwed;

    constructor(IConstantFlowAgreementV1 cfa, address _token) Ownable() ERC721("Total Return Swap", "TRS"){
        _cfa = cfa;
        token = _token;
    }

    event NewSwap(address _receiver, address _payer);

    /// @dev to be called by strategies. Anyone can make swaps. But it's the strategies that have the assets
    function newSwap(address _receiver, address _payer, int96 _requiredFlowRate, uint _amountUnderlying) external{
        (, int96 initialFlowRate,,) = _cfa.getFlow(ISuperToken(token), _payer,_receiver);
        require(ISwapReceiver(_receiver).verifyNewSwap(msg.sender,_amountUnderlying), "This receiver did not permit you to issue this swap");
        require(initialFlowRate >= _requiredFlowRate + payerRequiredFlowRates[_payer], 
            "Not paying enough to initialize this swap");

        _mintReceiver(_receiver,_amountUnderlying, msg.sender);         // note receiver will always have an even ID 0,2,4,ect.
        _mintPayer(_payer,_requiredFlowRate);                           // note payer will always have an odd ID 1,3,5,ect.
        emit NewSwap(_receiver, _payer);
    }

    // for working on later
    function settleBalances() external{}

    function _mintReceiver(address _receiver, uint _amountUnderlying, address _oracle) internal{
        _mint(_receiver,index); 
        // note this will need to use an oracle to get USD value
        asset memory a =asset(_amountUnderlying, _amountUnderlying, _oracle);
        _updateReceiverAssetsOwed(index,a);         
        index++;
 
    }
    function _mintPayer(address _payer, int96 _requiredFlowRate) internal{
        _mint(_payer,index); 
        payerRequiredFlowRates[_payer] = _requiredFlowRate;        
        index++;
    }

    function _updateReceiverAssetsOwed(uint _index, asset memory a) internal{
        require(_index % 2 == 0, "Can only updated assets owed for receivers");
        receiverAssetsOwed[_index] = a;
    }
}