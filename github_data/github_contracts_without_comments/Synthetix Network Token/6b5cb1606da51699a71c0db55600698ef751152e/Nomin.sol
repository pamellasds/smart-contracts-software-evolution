

pragma solidity 0.4.24;


import ;
import ;
import ;

contract nomin is feetoken {

    

    havven public havven;

    
    mapping(address => bool) public frozen;

    
    uint constant transfer_fee_rate = 15 * unit / 10000;
    string constant token_name = ;
    string constant token_symbol = ;

    

    constructor(address _proxy, tokenstate _tokenstate, havven _havven,
                uint _totalsupply,
                address _owner)
        feetoken(_proxy, _tokenstate,
                 token_name, token_symbol, _totalsupply,
                 transfer_fee_rate,
                 _havven, 
                 _owner)
        public
    {
        require(_proxy != 0, );
        require(address(_havven) != 0, );
        require(_owner != 0, );

        
        frozen[fee_address] = true;
        havven = _havven;
    }

    

    function sethavven(havven _havven)
        external
        optionalproxy_onlyowner
    {
        
        
        havven = _havven;
        setfeeauthority(_havven);
        emithavvenupdated(_havven);
    }


    

    
    function transfer(address to, uint value)
        public
        optionalproxy
        returns (bool)
    {
        require(!frozen[to], );
        return _transfer_byproxy(messagesender, to, value);
    }

    
    function transferfrom(address from, address to, uint value)
        public
        optionalproxy
        returns (bool)
    {
        require(!frozen[to], );
        return _transferfrom_byproxy(messagesender, from, to, value);
    }

    function transfersenderpaysfee(address to, uint value)
        public
        optionalproxy
        returns (bool)
    {
        require(!frozen[to], );
        return _transfersenderpaysfee_byproxy(messagesender, to, value);
    }

    function transferfromsenderpaysfee(address from, address to, uint value)
        public
        optionalproxy
        returns (bool)
    {
        require(!frozen[to], );
        return _transferfromsenderpaysfee_byproxy(messagesender, from, to, value);
    }

    
    function unfreezeaccount(address target)
        external
        optionalproxy_onlyowner
    {
        require(frozen[target] && target != fee_address, );
        frozen[target] = false;
        emitaccountunfrozen(target);
    }

    
    function issue(address account, uint amount)
        external
        onlyhavven
    {
        tokenstate.setbalanceof(account, safeadd(tokenstate.balanceof(account), amount));
        totalsupply = safeadd(totalsupply, amount);
        emittransfer(address(0), account, amount);
        emitissued(account, amount);
    }

    
    function burn(address account, uint amount)
        external
        onlyhavven
    {
        tokenstate.setbalanceof(account, safesub(tokenstate.balanceof(account), amount));
        totalsupply = safesub(totalsupply, amount);
        emittransfer(account, address(0), amount);
        emitburned(account, amount);
    }

    

    modifier onlyhavven() {
        require(havven(msg.sender) == havven, );
        _;
    }

    

    event havvenupdated(address newhavven);
    bytes32 constant havvenupdated_sig = keccak256();
    function emithavvenupdated(address newhavven) internal {
        proxy._emit(abi.encode(newhavven), 1, havvenupdated_sig, 0, 0, 0);
    }

    event accountfrozen(address indexed target, uint balance);
    bytes32 constant accountfrozen_sig = keccak256();
    function emitaccountfrozen(address target, uint balance) internal {
        proxy._emit(abi.encode(balance), 2, accountfrozen_sig, bytes32(target), 0, 0);
    }

    event accountunfrozen(address indexed target);
    bytes32 constant accountunfrozen_sig = keccak256();
    function emitaccountunfrozen(address target) internal {
        proxy._emit(abi.encode(), 2, accountunfrozen_sig, bytes32(target), 0, 0);
    }

    event issued(address indexed account, uint amount);
    bytes32 constant issued_sig = keccak256();
    function emitissued(address account, uint amount) internal {
        proxy._emit(abi.encode(amount), 2, issued_sig, bytes32(account), 0, 0);
    }

    event burned(address indexed account, uint amount);
    bytes32 constant burned_sig = keccak256();
    function emitburned(address account, uint amount) internal {
        proxy._emit(abi.encode(amount), 2, burned_sig, bytes32(account), 0, 0);
    }
}
