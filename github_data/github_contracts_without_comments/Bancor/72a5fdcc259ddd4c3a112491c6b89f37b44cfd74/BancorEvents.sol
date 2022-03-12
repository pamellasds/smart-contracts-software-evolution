pragma solidity ^0.4.10;



contract bancorevents {
    string public version = ;

    event newtoken(address _token);
    event tokenupdate(address indexed _token);
    event newtokenowner(address indexed _token, address indexed _prevowner, address indexed _newowner);
    event tokentransfer(address indexed _token, address indexed _from, address indexed _to, uint256 _value);
    event tokenapproval(address indexed _token, address indexed _owner, address indexed _spender, uint256 _value);
    event tokenchange(address indexed _sender, address indexed _fromtoken, address indexed _totoken, address _changer, uint256 _amount, uint256 _return);

    function bancorevents() {
    }

    function newtoken() public {
        newtoken(msg.sender);
    }

    function tokenupdate() public {
        tokenupdate(msg.sender);
    }

    function newtokenowner(address _prevowner, address _newowner) public {
        newtokenowner(msg.sender, _prevowner, _newowner);
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
