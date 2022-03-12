pragma solidity ^0.4.10;


contract bancoreventsinterface {
    function newtoken() public;
    function tokenownerupdate(address _prevowner, address _newowner) public;
    function tokenchangerupdate(address _prevchanger, address _newchanger) public;
    function tokentransfer(address _from, address _to, uint256 _value) public;
    function tokenapproval(address _owner, address _spender, uint256 _value) public;
    function tokenchange(address _fromtoken, address _totoken, address _changer, uint256 _amount, uint256 _return) public;
}
