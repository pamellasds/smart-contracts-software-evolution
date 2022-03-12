
pragma solidity 0.6.12;


abstract contract icontractregistry {
    function addressof(bytes32 _contractname) public virtual view returns (address);
}
