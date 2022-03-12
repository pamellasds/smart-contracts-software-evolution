

pragma solidity 0.4.24;


import ;
import ;
import ;
import ;

contract nomin is feetoken {

    

    
    court public court;
    havven public havven;

    
    mapping(address => bool) public frozen;

    
    uint constant transfer_fee_rate = 15 * unit / 10000;
    string constant token_name = ;
    string constant token_symbol = ;

    

    constructor(address _proxy, havven _havven, address _owner)
        feetoken(_proxy, token_name, token_symbol, 0, 
                 transfer_fee_rate,
                 _havven, 
                 _owner)
        public
    {
        require(_proxy != 0 && address(_havven) != 0 && _owner != 0);
        
        frozen[this] = true;
        havven = _havven;
    }

    

    function setcourt(court _court)
        external
        optionalproxy_onlyowner
    {
        court = _court;
        emitcourtupdated(_court);
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
        require(!frozen[to]);
        return _transfer_byproxy(messagesender, to, value);
    }

    
    function transferfrom(address from, address to, uint value)
        public
        optionalproxy
        returns (bool)
    {
        require(!frozen[to]);
        return _transferfrom_byproxy(messagesender, from, to, value);
    }

    function transfersenderpaysfee(address to, uint value)
        public
        optionalproxy
        returns (bool)
    {
        require(!frozen[to]);
        return _transfersenderpaysfee_byproxy(messagesender, to, value);
    }

    function transferfromsenderpaysfee(address from, address to, uint value)
        public
        optionalproxy
        returns (bool)
    {
        require(!frozen[to]);
        return _transferfromsenderpaysfee_byproxy(messagesender, from, to, value);
    }

    
    function freezeandconfiscate(address target)
        external
        onlycourt
    {
        
        
        uint motionid = court.targetmotionid(target);
        require(motionid != 0);

        
        
        require(court.motionconfirming(motionid));
        require(court.motionpasses(motionid));
        require(!frozen[target]);

        
        uint balance = tokenstate.balanceof(target);
        tokenstate.setbalanceof(address(this), safeadd(tokenstate.balanceof(address(this)), balance));
        tokenstate.setbalanceof(target, 0);
        frozen[target] = true;
        emitaccountfrozen(target, balance);
        emittransfer(target, address(this), balance);
    }

    
    function unfreezeaccount(address target)
        external
        optionalproxy_onlyowner
    {
        require(frozen[target] && target != address(this));
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
        require(havven(msg.sender) == havven);
        _;
    }

    modifier onlycourt() {
        require(court(msg.sender) == court);
        _;
    }

    

    event courtupdated(address newcourt);
    bytes32 constant courtupdated_sig = keccak256();
    function emitcourtupdated(address newcourt) internal {
        proxy._emit(abi.encode(newcourt), 1, courtupdated_sig, 0, 0, 0);
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
