pragma solidity ^0.4.23;


contract ibancorformula {
    function calculatepurchasereturn(uint256 _supply, uint256 _connectorbalance, uint32 _connectorweight, uint256 _depositamount) public view returns (uint256);
    function calculatesalereturn(uint256 _supply, uint256 _connectorbalance, uint32 _connectorweight, uint256 _sellamount) public view returns (uint256);
    function calculatecrossconnectorreturn(uint256 _fromconnectorbalance, uint32 _fromconnectorweight, uint256 _toconnectorbalance, uint32 _toconnectorweight, uint256 _amount) public view returns (uint256);
}
