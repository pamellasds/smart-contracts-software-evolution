













pragma solidity ^0.5.12;

import ;

contract gemlike {
    function decimals() public view returns (uint);
    function transfer(address,uint) external returns (bool);
    function transferfrom(address,address,uint) external returns (bool);
}

contract dstokenlike {
    function mint(address,uint) external;
    function burn(address,uint) external;
}

contract vatlike {
    function slip(bytes32,address,int) external;
    function move(address,address,uint) external;
}



contract gemjoin is libnote {
    
    mapping (address => uint) public wards;
    function rely(address usr) external note auth { wards[usr] = 1; }
    function deny(address usr) external note auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, );
        _;
    }

    vatlike public vat;   
    bytes32 public ilk;   
    gemlike public gem;
    uint    public dec;
    uint    public live;  

    constructor(address vat_, bytes32 ilk_, address gem_) public {
        wards[msg.sender] = 1;
        live = 1;
        vat = vatlike(vat_);
        ilk = ilk_;
        gem = gemlike(gem_);
        dec = gem.decimals();
    }
    function cage() external note auth {
        live = 0;
    }
    function join(address usr, uint wad) external note {
        require(live == 1, );
        require(int(wad) >= 0, );
        vat.slip(ilk, usr, int(wad));
        require(gem.transferfrom(msg.sender, address(this), wad), );
    }
    function exit(address usr, uint wad) external note {
        require(wad <= 2 ** 255, );
        vat.slip(ilk, msg.sender, int(wad));
        require(gem.transfer(usr, wad), );
    }
}

contract ethjoin is libnote {
    
    mapping (address => uint) public wards;
    function rely(address usr) external note auth { wards[usr] = 1; }
    function deny(address usr) external note auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, );
        _;
    }

    vatlike public vat;   
    bytes32 public ilk;   
    uint    public live;  

    constructor(address vat_, bytes32 ilk_) public {
        wards[msg.sender] = 1;
        live = 1;
        vat = vatlike(vat_);
        ilk = ilk_;
    }
    function cage() external note auth {
        live = 0;
    }
    function join(address usr) external payable note {
        require(live == 1, );
        require(int(msg.value) >= 0, );
        vat.slip(ilk, usr, int(msg.value));
    }
    function exit(address payable usr, uint wad) external note {
        require(int(wad) >= 0, );
        vat.slip(ilk, msg.sender, int(wad));
        usr.transfer(wad);
    }
}

contract daijoin is libnote {
    
    mapping (address => uint) public wards;
    function rely(address usr) external note auth { wards[usr] = 1; }
    function deny(address usr) external note auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, );
        _;
    }

    vatlike public vat;      
    dstokenlike public dai;  
    uint    public live;     

    constructor(address vat_, address dai_) public {
        wards[msg.sender] = 1;
        live = 1;
        vat = vatlike(vat_);
        dai = dstokenlike(dai_);
    }
    function cage() external note auth {
        live = 0;
    }
    uint constant one = 10 ** 27;
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function join(address usr, uint wad) external note {
        vat.move(address(this), usr, mul(one, wad));
        dai.burn(msg.sender, wad);
    }
    function exit(address usr, uint wad) external note {
        require(live == 1, );
        vat.move(msg.sender, address(this), mul(one, wad));
        dai.mint(usr, wad);
    }
}
