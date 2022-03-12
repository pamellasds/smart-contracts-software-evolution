pragma solidity ^0.4.11;


contract ibancorformula {
    function calculatepurchasereturn(uint256 _supply, uint256 _reservebalance, uint32 _reserveratio, uint256 _depositamount) public constant returns (uint256);
    function calculatesalereturn(uint256 _supply, uint256 _reservebalance, uint32 _reserveratio, uint256 _sellamount) public constant returns (uint256);
}
