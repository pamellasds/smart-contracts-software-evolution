pragma solidity ^0.5.16;


import ;



contract multicollateralsynth is synth {
    bytes32 public multicollateralkey;

    

    constructor(
        address payable _proxy,
        tokenstate _tokenstate,
        string memory _tokenname,
        string memory _tokensymbol,
        address _owner,
        bytes32 _currencykey,
        uint _totalsupply,
        address _resolver,
        bytes32 _multicollateralkey
    ) public synth(_proxy, _tokenstate, _tokenname, _tokensymbol, _owner, _currencykey, _totalsupply, _resolver) {
        multicollateralkey = _multicollateralkey;

        appendtoaddresscache(multicollateralkey);
    }

    

    function multicollateral() internal view returns (address) {
        return requireandgetaddress(multicollateralkey, );
    }

    

    
    function issue(address account, uint amount) external onlyinternalcontracts {
        super._internalissue(account, amount);
    }

    
    function burn(address account, uint amount) external onlyinternalcontracts {
        super._internalburn(account, amount);
    }

    

    
    modifier onlyinternalcontracts() {
        bool issynthetix = msg.sender == address(synthetix());
        bool isfeepool = msg.sender == address(feepool());
        bool isexchanger = msg.sender == address(exchanger());
        bool isissuer = msg.sender == address(issuer());
        bool ismulticollateral = msg.sender == address(multicollateral());

        require(
            issynthetix || isfeepool || isexchanger || isissuer || ismulticollateral,
            
        );
        _;
    }
}
