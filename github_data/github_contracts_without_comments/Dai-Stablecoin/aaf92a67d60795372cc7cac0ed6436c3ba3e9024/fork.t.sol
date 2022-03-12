pragma solidity ^0.5.12;

import ;
import ;

import {vat} from ;

contract usr {
    vat public vat;
    constructor(vat vat_) public {
        vat = vat_;
    }
    function try_call(address addr, bytes calldata data) external returns (bool) {
        bytes memory _data = data;
        assembly {
            let ok := call(gas, addr, 0, add(_data, 0x20), mload(_data), 0, 0)
            let free := mload(0x40)
            mstore(free, ok)
            mstore(0x40, add(free, 32))
            revert(free, 32)
        }
    }
    function can_frob(bytes32 ilk, address u, address v, address w, int dink, int dart) public returns (bool) {
        string memory sig = ;
        bytes memory data = abi.encodewithsignature(sig, ilk, u, v, w, dink, dart);

        bytes memory can_call = abi.encodewithsignature(, vat, data);
        (bool ok, bytes memory success) = address(this).call(can_call);

        ok = abi.decode(success, (bool));
        if (ok) return true;
    }
    function can_fork(bytes32 ilk, address src, address dst, int dink, int dart) public returns (bool) {
        string memory sig = ;
        bytes memory data = abi.encodewithsignature(sig, ilk, src, dst, dink, dart);

        bytes memory can_call = abi.encodewithsignature(, vat, data);
        (bool ok, bytes memory success) = address(this).call(can_call);

        ok = abi.decode(success, (bool));
        if (ok) return true;
    }
    function frob(bytes32 ilk, address u, address v, address w, int dink, int dart) public {
        vat.frob(ilk, u, v, w, dink, dart);
    }
    function fork(bytes32 ilk, address src, address dst, int dink, int dart) public {
        vat.fork(ilk, src, dst, dink, dart);
    }
    function hope(address usr) public {
        vat.hope(usr);
    }
    function pass() public {}
}

contract forktest is dstest {
    vat vat;
    usr ali;
    usr bob;
    address a;
    address b;

    function ray(uint wad) internal pure returns (uint) {
        return wad * 10 ** 9;
    }
    function rad(uint wad) internal pure returns (uint) {
        return wad * 10 ** 27;
    }

    function setup() public {
        vat = new vat();
        ali = new usr(vat);
        bob = new usr(vat);
        a = address(ali);
        b = address(bob);

        vat.init();
        vat.file(, , ray(0.5  ether));
        vat.file(, , rad(1000 ether));
        vat.file(,         rad(1000 ether));

        vat.slip(, a, 8 ether);
    }
    function test_fork_to_self() public {
        ali.frob(, a, a, a, 8 ether, 4 ether);
        asserttrue( ali.can_fork(, a, a, 8 ether, 4 ether));
        asserttrue( ali.can_fork(, a, a, 4 ether, 2 ether));
        asserttrue(!ali.can_fork(, a, a, 9 ether, 4 ether));
    }
    function test_give_to_other() public {
        ali.frob(, a, a, a, 8 ether, 4 ether);
        asserttrue(!ali.can_fork(, a, b, 8 ether, 4 ether));
        bob.hope(address(ali));
        asserttrue( ali.can_fork(, a, b, 8 ether, 4 ether));
    }
    function test_fork_to_other() public {
        ali.frob(, a, a, a, 8 ether, 4 ether);
        bob.hope(address(ali));
        asserttrue( ali.can_fork(, a, b, 4 ether, 2 ether));
        asserttrue(!ali.can_fork(, a, b, 4 ether, 3 ether));
        asserttrue(!ali.can_fork(, a, b, 4 ether, 1 ether));
    }
    function test_fork_dust() public {
        ali.frob(, a, a, a, 8 ether, 4 ether);
        bob.hope(address(ali));
        asserttrue( ali.can_fork(, a, b, 4 ether, 2 ether));
        vat.file(, , rad(1 ether));
        asserttrue( ali.can_fork(, a, b, 2 ether, 1 ether));
        asserttrue(!ali.can_fork(, a, b, 1 ether, 0.5 ether));
    }
}
