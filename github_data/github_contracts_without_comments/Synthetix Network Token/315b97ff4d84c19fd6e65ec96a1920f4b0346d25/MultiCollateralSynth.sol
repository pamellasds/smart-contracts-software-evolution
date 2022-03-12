

pragma solidity 0.4.25;

import ;

contract multicollateralsynth is synth {
    
    bytes32 public multicollateralkey;

    constructor(
        address _proxy,
        tokenstate _tokenstate,
        string _tokenname,
        string _tokensymbol,
        address _owner,
        bytes32 _currencykey,
        uint _totalsupply,
        address _resolver,
        bytes32 _multicollateralkey
    ) public synth(_proxy, _tokenstate, _tokenname, _tokensymbol, _owner, _currencykey, _totalsupply, _resolver) {
        multicollateralkey = _multicollateralkey;
    }

    

    function multicollateral() internal view returns (address) {
        address _foundaddress = resolver.getaddress(multicollateralkey);
        require(_foundaddress != address(0), );
        return _foundaddress;
    }

    

    
    function issue(address account, uint amount) external onlymulticollateralorsynthetix {
        super._internalissue(account, amount);
    }

    
    function burn(address account, uint amount) external onlymulticollateralorsynthetix {
        super._internalburn(account, amount);
    }

    

    
    modifier onlymulticollateralorsynthetix() {
        bool issynthetix = msg.sender == address(synthetix());
        bool ismulticollateral = msg.sender == address(multicollateral());

        require(ismulticollateral || issynthetix, );
        _;
    }
}
