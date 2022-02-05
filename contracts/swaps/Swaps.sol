// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// initializing the CFA Library
import {CFAv1Library} from "@superfluid-finance/ethereum-contracts/contracts/apps/CFAv1Library.sol";
import "../interfaces/ISwapReceiver.sol";

contract Swaps is ERC721, Ownable{

    using CFAv1Library for CFAv1Library.InitData;
    
    //initialize cfaV1 variable
    CFAv1Library.InitData public cfaV1;

    address public token;
    mapping(uint => uint) public payerRequiredFlowRates;        //Required payments for each payer NFT

    struct asset{
        uint amountUnderlyingExposed;
        uint priceUSD;
    }

    mapping(uint => asset) public receiverAssetsOwed;

    constructor(ISuperfluid host, address _token) Ownable() ERC721("Total Return Swap", "TRS"){
        //initialize InitData struct, and set equal to cfaV1
        cfaV1 = CFAv1Library.InitData(
            host,
            //here, we are deriving the address of the CFA using the host contract
            IConstantFlowAgreementV1(
                address(host.getAgreementClass(
                        keccak256("org.superfluid-finance.agreements.ConstantFlowAgreement.v1")
                    ))
                )
            );
        token = _token;
    }

    event NewSwap(address _receiver, address _payer);

    /// @dev to be called by strategies. Anyone can make swaps. But it's the strategies that have the assets
    function newSwap(address _receiver, address _payer, uint _requiredFlowRate, uint _amountUnderlying) external{
        (, int96 initialFlowRate,,) = CFAv1Library.InitData.cfa.getFlow(token, _payer,_receiver);
        require(ISwapReceiver(_receiver).verifyNewSwap(msg.sender,_amountUnderlying), "This receiver did not permit you to issue this swap");
        require(initialFlowRate >= _requiredFlowRate, "Not paying enough to initialize this swap");

        _mintReceiver(_receiver,_amountUnderlying);         // note receiver will always have an even ID 0,2,4,ect.
        _mintPayer(_payer,_requiredFlowRate);               // note payer will always have an odd ID 1,3,5,ect.
        emit NewSwap(_receiver, _payer);
    }

    // for working on later
    function settleBalances() external{}

    function _mintReceiver(address _receiver, uint _amountUnderlying) internal{
        _mint(_receiver,index); 
        // note this will need to use an oracle to get USD value
        asset memory a =asset(_amountUnderlying, _amountUnderlying);
        _updateReceiverAssetsOwed(index,a);         
        index++;
 
    }
    function _mintPayer(address _payer, uint _requiredFlowRate) internal{
        _mint(_payer,index); 
        _updatePayerRequiredFlowRates(index,_requiredFlowRate);         
        index++;
    }

    function _updatePayerRequiredFlowRates(uint _index, uint _requiredFlowRate) internal{
        require(index % 2 == 1, "Can only updated flow rates for payers");
        payerRequiredFlowRates[index] = _requiredFlowRate;
    }

    function _updateReceiverAssetsOwed(uint _index, asset memory a) internal{
        require(index % 2 == 0, "Can only updated assets owed for receivers");
        receiverAssetsOwed[index] = a;
    }
}