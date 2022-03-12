pragma solidity 0.4.26;


contract ibancorformula {
    function calculatepurchasereturn(uint256 _supply, uint256 _reservebalance, uint32 _reserveratio, uint256 _depositamount) public view returns (uint256);
    function calculatesalereturn(uint256 _supply, uint256 _reservebalance, uint32 _reserveratio, uint256 _sellamount) public view returns (uint256);
    function calculatecrossreservereturn(uint256 _fromreservebalance, uint32 _fromreserveratio, uint256 _toreservebalance, uint32 _toreserveratio, uint256 _amount) public view returns (uint256);
    
    function calculatecrossconnectorreturn(uint256 _fromconnectorbalance, uint32 _fromconnectorweight, uint256 _toconnectorbalance, uint32 _toconnectorweight, uint256 _amount) public view returns (uint256);
}
