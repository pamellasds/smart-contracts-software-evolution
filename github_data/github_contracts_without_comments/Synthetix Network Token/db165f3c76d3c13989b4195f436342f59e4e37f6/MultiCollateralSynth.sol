


pragma solidity 0.4.25;

import ;

contract multicollateralsynth is synth {

    
    address public multicollateral;

    

    constructor(address _proxy, tokenstate _tokenstate, address _synthetixproxy, address _feepoolproxy,
        string _tokenname, string _tokensymbol, address _owner, bytes32 _currencykey, uint _totalsupply, address _multicollateral
    )
        synth(_proxy, _tokenstate, _synthetixproxy, _feepoolproxy, _tokenname, _tokensymbol, _owner, _currencykey, _totalsupply)
        public
    {
        multicollateral = _multicollateral;
    }

    

    
    function issue(address account, uint amount)
        external
        onlymulticollateralorsynthetix
    {
        super._internalissue(account, amount);
    }
    
    
    function burn(address account, uint amount)
        external
        onlymulticollateralorsynthetix
    {
        super._internalburn(account, amount);
    }
    
    

    function setmulticollateral(address _multicollateral)
        external
        optionalproxy_onlyowner
    {
        multicollateral = _multicollateral;
        emitmulticollateralupdated(_multicollateral);
    }


    

    modifier onlymulticollateralorsynthetix() {
        bool issynthetix = msg.sender == address(proxy(synthetixproxy).target());
        bool ismulticollateral = (messagesender == multicollateral || msg.sender == multicollateral);

        require(ismulticollateral || issynthetix, );
        _;
    }

    
    event multicollateralupdated(address newmulticollateral);
    bytes32 constant multicollateralupdated_sig = keccak256();
    function emitmulticollateralupdated(address newmulticollateral) internal {
        proxy._emit(abi.encode(newmulticollateral), 1, multicollateralupdated_sig, 0, 0, 0);
    }
}
