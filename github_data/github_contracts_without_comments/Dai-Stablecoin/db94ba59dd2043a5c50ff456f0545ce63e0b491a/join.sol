













pragma solidity ^0.4.20;

import ;

contract gemlike {
    function transferfrom(address,address,uint) public returns (bool);
    function mint(address,uint) public;
    function burn(address,uint) public;
}

contract vatlike {
    function slip(bytes32,bytes32,int) public;
    function move(bytes32,bytes32,int) public;
    function flux(bytes32,bytes32,bytes32,int) public;
}

contract adapter is dsnote {
    vatlike public vat;
    bytes32 public ilk;
    gemlike public gem;
    constructor(address vat_, bytes32 ilk_, address gem_) public {
        vat = vatlike(vat_);
        ilk = ilk_;
        gem = gemlike(gem_);
    }
    uint constant one = 10 ** 27;
    function mul(uint x, uint y) internal pure returns (int z) {
        z = int(x * y);
        require(int(z) >= 0);
        require(y == 0 || uint(z) / y == x);
    }
    function join(bytes32 urn, uint wad) public note {
        require(gem.transferfrom(msg.sender, this, wad));
        vat.slip(ilk, urn, mul(one, wad));
    }
    function exit(address guy, uint wad) public note {
        require(gem.transferfrom(this, guy, wad));
        vat.slip(ilk, bytes32(msg.sender), mul(one, wad));
    }
}

contract ethadapter is dsnote {
    vatlike public vat;
    bytes32 public ilk;
    constructor(address vat_, bytes32 ilk_) public {
        vat = vatlike(vat_);
        ilk = ilk_;
    }
    uint constant one = 10 ** 27;
    function mul(uint x, uint y) internal pure returns (int z) {
        z = int(x * y);
        require(int(z) >= 0);
        require(y == 0 || uint(z) / y == x);
    }
    function join(bytes32 urn) public payable note {
        vat.slip(ilk, urn, mul(one, msg.value));
    }
    function exit(address guy, uint wad) public note {
        guy.transfer(wad);
        vat.slip(ilk, bytes32(msg.sender), mul(one, wad));
    }
}

contract daiadapter is dsnote {
    vatlike public vat;
    gemlike public dai;
    constructor(address vat_, address dai_) public {
        vat = vatlike(vat_);
        dai = gemlike(dai_);
    }
    uint constant one = 10 ** 27;
    function mul(uint x, uint y) internal pure returns (int z) {
        z = int(x * y);
        require(int(z) >= 0);
        require(y == 0 || uint(z) / y == x);
    }
    function join(bytes32 urn, uint wad) public note {
        vat.move(bytes32(address(this)), urn, mul(one, wad));
        dai.burn(msg.sender, wad);
    }
    function exit(address guy, uint wad) public note {
        vat.move(bytes32(msg.sender), bytes32(address(this)), mul(one, wad));
        dai.mint(guy, wad);
    }
}
