// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from './PriceConverter.sol';

error NotOwner();


contract FundMe {
   using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;

     constructor() {
           i_owner = msg.sender;
     }

    function fund() public payable {
      
        require(msg.value.getConversionRate()>= MINIMUM_USD,"didn't send enough eth"); // 1e18 = 1ETH = 1* 10 base 18 wei
        funders.push(msg.sender); // whoever call this function
          addressToAmountFunded[msg.sender] += msg.value;
    }
   function withdraw() public onlyOwner{
     for(uint256 funderIndex = 0; funderIndex <funders.length; funderIndex++){
         address funder = funders[funderIndex];
         addressToAmountFunded[funder] =0;
     }
     funders = new address[](0); // resetting the array
     //using transfer
    //  payable(msg.sender).transfer(address(this).balance); // sending eth
    //  //send
    //  bool sendSuccess = payable(msg.sender).send(address(this).balance);
    //  require(sendSuccess ,"Send Failed");
     //call
    (bool callSuccess,)= payable(msg.sender).call{value: address(this).balance}("");
    require(callSuccess ,"Call Failed");
   }

   modifier onlyOwner(){
    if (msg.sender != i_owner) revert NotOwner();
    _;
   } 
   // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

}
