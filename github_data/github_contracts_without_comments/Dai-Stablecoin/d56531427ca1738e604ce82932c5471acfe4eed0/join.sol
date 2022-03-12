













pragma solidity ^0.4.20;

contract gemlike {
    function move(address,address,uint) public;  
}

contract fluxing {
    function slip(bytes32,address,int) public;
}

contract adapter {
    fluxing public vat;
    bytes32 public ilk;
    gemlike public gem;
    constructor(address vat_, bytes32 ilk_, address gem_) public {
        vat = fluxing(vat_);
        ilk = ilk_;
        gem = gemlike(gem_);
    }
    function join(uint wad) public {
        require(int(wad) >= 0);
        gem.move(msg.sender, this, wad);
        vat.slip(ilk, msg.sender, int(wad));
    }
    function exit(uint wad) public {
        require(int(wad) >= 0);
        gem.move(this, msg.sender, wad);
        vat.slip(ilk, msg.sender, int(wad));
    }
}
