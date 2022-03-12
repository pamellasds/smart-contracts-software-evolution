pragma solidity ^0.4.10;
import ;



contract bancorevents is bancoreventsinterface {
    string public version = ;

    event newtoken(address _token);
    event tokenownerupdate(address indexed _token, address _prevowner, address _newowner);
    event tokenchangerupdate(address indexed _token, address _prevchanger, address _newchanger);
    event tokentransfer(address indexed _token, address indexed _from, address indexed _to, uint256 _value);
    event tokenapproval(address indexed _token, address indexed _owner, address indexed _spender, uint256 _value);
    event tokenchange(address indexed _sender, address indexed _fromtoken, address indexed _totoken, address _changer, uint256 _amount, uint256 _return);

    function bancorevents() {
    }

    function newtoken() public {
        newtoken(msg.sender);
    }

    function tokenownerupdate(address _prevowner, address _newowner) public {
        tokenownerupdate(msg.sender, _prevowner, _newowner);
    }

    function tokenchangerupdate(address _prevchanger, address _newchanger) public {
        tokenchangerupdate(msg.sender, _prevchanger, _newchanger);
    }

    function tokentransfer(address _from, address _to, uint256 _value) public {
        tokentransfer(msg.sender, _from, _to, _value);
    }

    function tokenapproval(address _owner, address _spender, uint256 _value) public {
        tokenapproval(msg.sender, _owner, _spender, _value);
    }

    function tokenchange(address _fromtoken, address _totoken, address _changer, uint256 _amount, uint256 _return) public {
        tokenchange(msg.sender, _fromtoken, _totoken, _changer, _amount, _return);
    }

    function() {
        assert(false);
    }
}
