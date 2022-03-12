













pragma solidity ^0.4.20;

contract gemlike {
    function transferfrom(address,address,uint) public returns (bool);
}

contract vatlike {
    function slip(bytes32,bytes32,int) public;
    function move(bytes32,bytes32,uint) public;
}

contract adapter {
    vatlike public vat;
    bytes32 public ilk;
    gemlike public gem;
    constructor(address vat_, bytes32 ilk_, address gem_) public {
        vat = vatlike(vat_);
        ilk = ilk_;
        gem = gemlike(gem_);
    }
    function join(uint wad) public {
        require(int(wad) >= 0);
        require(gem.transferfrom(msg.sender, this, wad));
        vat.slip(ilk, bytes32(msg.sender), int(wad));
    }
    function exit(uint wad) public {
        require(int(wad) >= 0);
        require(gem.transferfrom(this, msg.sender, wad));
        vat.slip(ilk, bytes32(msg.sender), int(wad));
    }
}

contract ethadapter {
    vatlike public vat;
    bytes32 public ilk;
    constructor(address vat_, bytes32 ilk_) public {
        vat = vatlike(vat_);
        ilk = ilk_;
    }
    function join() public payable {
        vat.slip(ilk, bytes32(msg.sender), int(msg.value));
    }
    function exit(uint wad) public {
        require(int(wad) >= 0);
        vat.slip(ilk, bytes32(msg.sender), int(wad));
        msg.sender.transfer(wad);
    }
}

contract dstoken {
    function mint(address,uint) public;
    function burn(address,uint) public;
}

contract daiadapter {
    vatlike public vat;
    dstoken public dai;
    constructor(address vat_, address dai_) public {
        vat = vatlike(vat_);
        dai = dstoken(dai_);
    }
    uint constant one = 10 ** 27;
    function join(uint wad) public {
        vat.move(bytes32(address(this)), bytes32(msg.sender), wad * one);
        dai.burn(msg.sender, wad);
    }
    function exit(uint wad) public {
        vat.move(bytes32(msg.sender), bytes32(address(this)), wad * one);
        dai.mint(msg.sender, wad);
    }
}
