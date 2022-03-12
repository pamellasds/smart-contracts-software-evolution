

pragma solidity 0.4.25;

import ;
import ;
import ;
import ;
import ;
import ;


contract externstatetoken is selfdestructible, proxyable, tokenfallbackcaller {

    using safemath for uint;
    using safedecimalmath for uint;

    

    
    tokenstate public tokenstate;

    
    string public name;
    string public symbol;
    uint public totalsupply;
    uint8 public decimals;

    
    constructor(address _proxy, tokenstate _tokenstate,
                string _name, string _symbol, uint _totalsupply,
                uint8 _decimals, address _owner)
        selfdestructible(_owner)
        proxyable(_proxy, _owner)
        public
    {
        tokenstate = _tokenstate;

        name = _name;
        symbol = _symbol;
        totalsupply = _totalsupply;
        decimals = _decimals;
    }

    

    
    function allowance(address owner, address spender)
        public
        view
        returns (uint)
    {
        return tokenstate.allowance(owner, spender);
    }

    
    function balanceof(address account)
        public
        view
        returns (uint)
    {
        return tokenstate.balanceof(account);
    }

    

     
    function settokenstate(tokenstate _tokenstate)
        external
        optionalproxy_onlyowner
    {
        tokenstate = _tokenstate;
        emittokenstateupdated(_tokenstate);
    }

    function _internaltransfer(address from, address to, uint value, bytes data) 
        internal
        returns (bool)
    { 
        
        require(to != address(0), );
        require(to != address(this), );
        require(to != address(proxy), );

        
        tokenstate.setbalanceof(from, tokenstate.balanceof(from).sub(value));
        tokenstate.setbalanceof(to, tokenstate.balanceof(to).add(value));

        
        
        
        calltokenfallbackifneeded(from, to, value, data);
        
        
        emittransfer(from, to, value);

        return true;
    }

    
    function _transfer_byproxy(address from, address to, uint value, bytes data)
        internal
        returns (bool)
    {
        return _internaltransfer(from, to, value, data);
    }

    
    function _transferfrom_byproxy(address sender, address from, address to, uint value, bytes data)
        internal
        returns (bool)
    {
        
        tokenstate.setallowance(from, sender, tokenstate.allowance(from, sender).sub(value));
        return _internaltransfer(from, to, value, data);
    }

    
    function approve(address spender, uint value)
        public
        optionalproxy
        returns (bool)
    {
        address sender = messagesender;

        tokenstate.setallowance(sender, spender, value);
        emitapproval(sender, spender, value);
        return true;
    }

    

    event transfer(address indexed from, address indexed to, uint value);
    bytes32 constant transfer_sig = keccak256();
    function emittransfer(address from, address to, uint value) internal {
        proxy._emit(abi.encode(value), 3, transfer_sig, bytes32(from), bytes32(to), 0);
    }

    event approval(address indexed owner, address indexed spender, uint value);
    bytes32 constant approval_sig = keccak256();
    function emitapproval(address owner, address spender, uint value) internal {
        proxy._emit(abi.encode(value), 3, approval_sig, bytes32(owner), bytes32(spender), 0);
    }

    event tokenstateupdated(address newtokenstate);
    bytes32 constant tokenstateupdated_sig = keccak256();
    function emittokenstateupdated(address newtokenstate) internal {
        proxy._emit(abi.encode(newtokenstate), 1, tokenstateupdated_sig, 0, 0, 0);
    }
}
