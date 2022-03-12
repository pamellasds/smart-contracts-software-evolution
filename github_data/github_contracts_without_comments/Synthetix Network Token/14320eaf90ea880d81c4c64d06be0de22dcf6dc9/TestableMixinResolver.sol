pragma solidity ^0.5.16;

import ;
import ;


contract testablemixinresolver is owned, mixinresolver {
    bytes32 private constant contract_example_1 = ;
    bytes32 private constant contract_example_2 = ;
    bytes32 private constant contract_example_3 = ;

    bytes32[24] private addressestocache = [contract_example_1, contract_example_2, contract_example_3];

    constructor(address _owner, address _resolver) public owned(_owner) mixinresolver(_resolver, addressestocache) {}
}
