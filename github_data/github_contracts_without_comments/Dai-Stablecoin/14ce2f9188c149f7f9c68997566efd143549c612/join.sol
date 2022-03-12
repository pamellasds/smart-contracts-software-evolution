













pragma solidity ^0.4.20;

contract gemlike {
    function transferfrom(address,address,uint) public returns (bool);
}

contract vatlike {
    function slip(bytes32,bytes32,int) public;
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
