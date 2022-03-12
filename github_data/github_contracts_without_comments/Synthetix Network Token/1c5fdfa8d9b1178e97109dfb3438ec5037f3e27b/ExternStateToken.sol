pragma solidity ^0.5.16;


import ;
import ;
import ;


import ;


import ;



contract externstatetoken is owned, selfdestructible, proxyable {
    using safemath for uint;
    using safedecimalmath for uint;

    

    
    tokenstate public tokenstate;

    
    string public name;
    string public symbol;
    uint public totalsupply;
    uint8 public decimals;

    constructor(
        address payable _proxy,
        tokenstate _tokenstate,
        string memory _name,
        string memory _symbol,
        uint _totalsupply,
        uint8 _decimals,
        address _owner
    ) public owned(_owner) selfdestructible() proxyable(_proxy) {
        tokenstate = _tokenstate;

        name = _name;
        symbol = _symbol;
        totalsupply = _totalsupply;
        decimals = _decimals;
    }

    

    
    function allowance(address owner, address spender) public view returns (uint) {
        return tokenstate.allowance(owner, spender);
    }

    
    function balanceof(address account) external view returns (uint) {
        return tokenstate.balanceof(account);
    }

    

    
    function settokenstate(tokenstate _tokenstate) external optionalproxy_onlyowner {
        tokenstate = _tokenstate;
        emittokenstateupdated(address(_tokenstate));
    }

    function _internaltransfer(
        address from,
        address to,
        uint value
    ) internal returns (bool) {
        
        require(to != address(0) && to != address(this) && to != address(proxy), );

        
        tokenstate.setbalanceof(from, tokenstate.balanceof(from).sub(value));
        tokenstate.setbalanceof(to, tokenstate.balanceof(to).add(value));

        
        emittransfer(from, to, value);

        return true;
    }

    
    function _transferbyproxy(
        address from,
        address to,
        uint value
    ) internal returns (bool) {
        return _internaltransfer(from, to, value);
    }

    
    function _transferfrombyproxy(
        address sender,
        address from,
        address to,
        uint value
    ) internal returns (bool) {
        
        tokenstate.setallowance(from, sender, tokenstate.allowance(from, sender).sub(value));
        return _internaltransfer(from, to, value);
    }

    
    function approve(address spender, uint value) public optionalproxy returns (bool) {
        address sender = messagesender;

        tokenstate.setallowance(sender, spender, value);
        emitapproval(sender, spender, value);
        return true;
    }

    
    function addresstobytes32(address input) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(input)));
    }

    event transfer(address indexed from, address indexed to, uint value);
    bytes32 internal constant transfer_sig = keccak256();

    function emittransfer(
        address from,
        address to,
        uint value
    ) internal {
        proxy._emit(abi.encode(value), 3, transfer_sig, addresstobytes32(from), addresstobytes32(to), 0);
    }

    event approval(address indexed owner, address indexed spender, uint value);
    bytes32 internal constant approval_sig = keccak256();

    function emitapproval(
        address owner,
        address spender,
        uint value
    ) internal {
        proxy._emit(abi.encode(value), 3, approval_sig, addresstobytes32(owner), addresstobytes32(spender), 0);
    }

    event tokenstateupdated(address newtokenstate);
    bytes32 internal constant tokenstateupdated_sig = keccak256();

    function emittokenstateupdated(address newtokenstate) internal {
        proxy._emit(abi.encode(newtokenstate), 1, tokenstateupdated_sig, 0, 0, 0);
    }
}
