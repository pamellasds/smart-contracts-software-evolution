













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
    function join(bytes32 urn, uint wad) public note {
        require(int(wad) >= 0);
        require(gem.transferfrom(msg.sender, this, wad));
        vat.slip(ilk, urn, int(wad));
    }
    function exit(address guy, uint wad) public note {
        require(int(wad) >= 0);
        require(gem.transferfrom(this, guy, wad));
        vat.slip(ilk, bytes32(msg.sender), int(wad));
    }

    mapping(address => mapping (address => bool)) public can;
    function hope(address guy) public {
        can[msg.sender][guy] = true;
    }
    function move(address src, address dst, uint wad) public {
        require(int(wad) >= 0);
        require(can[src][msg.sender]);
        vat.flux(ilk, bytes32(src), bytes32(dst), int(wad));
    }
    function push(bytes32 urn, uint wad) public {
        require(int(wad) >= 0);
        vat.flux(bytes32(msg.sender), urn, int(wad));
    }
}

contract ethadapter is dsnote {
    vatlike public vat;
    bytes32 public ilk;
    constructor(address vat_, bytes32 ilk_) public {
        vat = vatlike(vat_);
        ilk = ilk_;
    }
    function join(bytes32 urn) public payable note {
        vat.slip(ilk, urn, int(msg.value));
    }
    function exit(address guy, uint wad) public note {
        require(int(wad) >= 0);
        vat.slip(ilk, bytes32(msg.sender), int(wad));
        guy.transfer(wad);
    }

    mapping(address => mapping (address => bool)) public can;
    function hope(address guy, bool ok) public {
        can[msg.sender][guy] = ok;
    }
    function move(address src, address dst, uint wad) public {
        require(int(wad) >= 0);
        require(can[src][msg.sender]);
        vat.flux(ilk, bytes32(src), bytes32(dst), int(wad));
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
    function join(bytes32 urn, uint wad) public note {
        require(int(wad * one) >= 0);
        vat.move(bytes32(address(this)), urn, int(wad * one));
        dai.burn(msg.sender, wad);
    }
    function exit(address guy, uint wad) public note {
        require(int(wad * one) >= 0);
        vat.move(bytes32(msg.sender), bytes32(address(this)), int(wad * one));
        dai.mint(guy, wad);
    }

    mapping(address => mapping (address => bool)) public can;
    function hope(address guy, bool ok) public {
        can[msg.sender][guy] = ok;
    }
    function move(address src, address dst, uint wad) public {
        require(int(wad) >= 0);
        require(can[src][msg.sender]);
        vat.move(bytes32(src), bytes32(dst), int(wad));
    }
}
