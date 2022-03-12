













pragma solidity ^0.4.24;

contract vatlike {
    function dai(address) public view returns (int);
    function tab() public view returns (uint);
    function move(address,address,uint) public;
}

contract dai20 {
    vatlike public vat;
    constructor(address vat_) public  { vat = vatlike(vat_); }

    uint256 constant one = 10 ** 27;

    function balanceof(address guy) public view returns (uint) {
        return uint(vat.dai(guy)) / one;
    }
    function totalsupply() public view returns (uint) {
        return vat.tab() / one;
    }

    event approval(address src, address dst, uint wad);
    event transfer(address src, address dst, uint wad);

    mapping (address => mapping (address => uint)) public allowance;
    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] += wad;
        emit approval(msg.sender, guy, wad * uint(1));
        return true;
    }
    function approve(address guy) public {
        approve(guy, uint(1));
    }

    function transferfrom(address src, address dst, uint wad) public returns (bool) {
        if (src != msg.sender && allowance[src][msg.sender] != uint(1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] = wad;
        }
        vat.move(src, dst, wad);
        emit transfer(src, dst, wad);
        return true;
    }
    function transfer(address guy, uint wad) public returns (bool) {
        transferfrom(msg.sender, guy, wad);
        return true;
    }

    function move(address src, address dst, uint wad) public {
        transferfrom(src, dst, wad);
    }
    function push(address dst, uint wad) public {
        transferfrom(msg.sender, dst, wad);
    }
    function pull(address src, uint wad) public {
        transferfrom(src, msg.sender, wad);
    }
}
