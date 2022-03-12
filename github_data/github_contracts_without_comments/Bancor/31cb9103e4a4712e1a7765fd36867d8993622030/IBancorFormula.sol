pragma solidity ^0.4.18;


contract ibancorformula {
    function calculatepurchasereturn(uint256 _supply, uint256 _connectorbalance, uint32 _connectorweight, uint256 _depositamount) public view returns (uint256);
    function calculatesalereturn(uint256 _supply, uint256 _connectorbalance, uint32 _connectorweight, uint256 _sellamount) public view returns (uint256);
    function calculatecrossconnectorreturn(uint256 _connector1balance, uint32 _connector1weight, uint256 _connector2balance, uint32 _connector2weight, uint256 _amount) public view returns (uint256);
}
