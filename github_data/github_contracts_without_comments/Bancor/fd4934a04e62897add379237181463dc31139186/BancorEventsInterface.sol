pragma solidity ^0.4.10;


contract bancoreventsinterface {
    event newtoken(address _token);
    event tokenownerupdate(address indexed _token, address _prevowner, address _newowner);
    event tokenchangerupdate(address indexed _token, address _prevchanger, address _newchanger);
    event tokensupplyupdate(address indexed _token, uint256 _totalsupply);
    event tokentransfer(address indexed _token, address indexed _from, address indexed _to, uint256 _value);
    event tokenapproval(address indexed _token, address indexed _owner, address indexed _spender, uint256 _value);
    event tokenchange(address indexed _sender, address indexed _fromtoken, address indexed _totoken, address _changer, uint256 _amount, uint256 _return);

    function newtoken() public;
    function tokenownerupdate(address _prevowner, address _newowner) public;
    function tokenchangerupdate(address _prevchanger, address _newchanger) public;
    function tokensupplyupdate(uint256 _totalsupply) public;
    function tokentransfer(address _from, address _to, uint256 _value) public;
    function tokenapproval(address _owner, address _spender, uint256 _value) public;
    function tokenchange(address _fromtoken, address _totoken, address _changer, uint256 _amount, uint256 _return) public;
}
