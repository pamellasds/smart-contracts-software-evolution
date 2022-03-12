pragma solidity ^0.4.9;



contract bancorevents {
    string public version = ;

    event newtoken(address _token);
    event tokenupdate(address _token);
    event tokentransfer(address indexed _token, address indexed _from, address indexed _to, uint256 _value);
    event tokenapproval(address indexed _token, address indexed _owner, address indexed _spender, uint256 _value);
    event tokenconversion(address indexed _token, address indexed _reservetoken, address indexed _trader, bool _ispurchase,
                          uint256 _totalsupply, uint256 _reservebalance, uint256 _tokenamount, uint256 _reserveamount);

    function bancorevents() {
    }

    function newtoken() public {
        newtoken(msg.sender);
    }

    function tokenupdate() public {
        tokenupdate(msg.sender);
    }

    function tokentransfer(address _from, address _to, uint256 _value) public {
        tokentransfer(msg.sender, _from, _to, _value);
    }

    function tokenapproval(address _owner, address _spender, uint256 _value) public {
        tokenapproval(msg.sender, _owner, _spender, _value);
    }

    function tokenconversion(address _reservetoken, address _trader, bool _ispurchase, uint256 _totalsupply,
                             uint256 _reservebalance, uint256 _tokenamount, uint256 _reserveamount) public {
        tokenconversion(msg.sender, _reservetoken, _trader, _ispurchase, _totalsupply, _reservebalance, _tokenamount, _reserveamount);
    }

    function() {
        throw;
    }
}
