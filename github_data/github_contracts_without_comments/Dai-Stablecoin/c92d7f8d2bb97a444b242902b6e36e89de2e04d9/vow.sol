













pragma solidity >=0.5.0;

import ;

contract flopper {
    function kick(address gal, uint lot, uint bid) external returns (uint);
    function cage() external;
    function live() external returns (uint);
}

contract flapper {
    function kick(uint lot, uint bid) external returns (uint);
    function cage(uint) external;
    function live() external returns (uint);
}

contract vatlike {
    function dai (address) external view returns (uint);
    function sin (address) external view returns (uint);
    function heal(uint256) external;
    function hope(address) external;
}

contract vow is dsnote {
    
    mapping (address => uint) public wards;
    function rely(address usr) external note auth { wards[usr] = 1; }
    function deny(address usr) external note auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    
    vatlike public vat;
    flapper public flapper;
    flopper public flopper;

    mapping (uint256 => uint256) public sin; 
    uint256 public sin;   
    uint256 public ash;   

    uint256 public wait;  
    uint256 public dump;  
    uint256 public sump;  

    uint256 public bump;  
    uint256 public hump;  

    uint256 public live;

    
    constructor(address vat_, address flapper_, address flopper_) public {
        wards[msg.sender] = 1;
        vat     = vatlike(vat_);
        flapper = flapper(flapper_);
        flopper = flopper(flopper_);
        vat.hope(flapper_);
        live = 1;
    }

    
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x  y) <= x);
    }
    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }

    
    function file(bytes32 what, uint data) external note auth {
        if (what == ) wait = data;
        else if (what == ) bump = data;
        else if (what == ) sump = data;
        else if (what == ) dump = data;
        else if (what == ) hump = data;
        else revert();
    }

    
    function fess(uint tab) external note auth {
        sin[now] = add(sin[now], tab);
        sin = add(sin, tab);
    }
    
    function flog(uint era) external note {
        require(add(era, wait) <= now);
        sin = sub(sin, sin[era]);
        sin[era] = 0;
    }

    
    function heal(uint rad) external note {
        require(rad <= vat.dai(address(this)));
        require(rad <= sub(sub(vat.sin(address(this)), sin), ash));
        vat.heal(rad);
    }
    function kiss(uint rad) external note {
        require(rad <= ash);
        require(rad <= vat.dai(address(this)));
        ash = sub(ash, rad);
        vat.heal(rad);
    }

    
    function flop() external note returns (uint id) {
        require(sump <= sub(sub(vat.sin(address(this)), sin), ash));
        require(vat.dai(address(this)) == 0);
        ash = add(ash, sump);
        id = flopper.kick(address(this), dump, sump);
    }
    
    function flap() external note returns (uint id) {
        require(vat.dai(address(this)) >= add(add(vat.sin(address(this)), bump), hump));
        require(sub(sub(vat.sin(address(this)), sin), ash) == 0);
        id = flapper.kick(bump, 0);
    }

    function cage() external note auth {
        live = 0;
        sin = 0;
        ash = 0;
        flapper.cage(vat.dai(address(flapper)));
        flopper.cage();
        vat.heal(min(vat.dai(address(this)), vat.sin(address(this))));
    }
}
